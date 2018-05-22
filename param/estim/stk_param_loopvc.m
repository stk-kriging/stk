% STK_PARAM_LOOPVC computes a Leave-One-Out criterion of a model given data
%
% CALL: [LOOPVC, dLOOPVC_dtheta, dLOOPVC_dLNV] = stk_param_loopvc (MODEL, XI, YI)
%
%   computes the Leave-One-Out predictive variance criterion (denoted by
%   LOOPVC) of MODEL given the data (XI, YI). The function also returns
%   the gradient dLOOPVC_dtheta of LOOPVC with respect to the parameters
%   of the covariance function and the derivative dLOOPVC_dLNV of LOOPVC
%   with respect to the logarithm of the noise variance.
%
% REFERENCE
%
%   [1] Francois Bachoc. Estimation parametrique de la fonction de covariance
%       dans le modele de krigeage par processus gaussiens: application a la
%       quantification des incertitudes en simulation numerique.
%       PhD thesis, Paris 7, 2013. http://www.theses.fr/2013PA077111
%
% See also: stk_param_loomse, stk_predict_leaveoneout, stk_param_relik

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%    Copyright (C) 2018 LNE
%
%    Authors:  Remi Stroh  <remi.stroh@lne.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function [lp, dlp_cov_param, dlp_noise_param] = stk_param_loopvc (model, xi, yi)

yi = double(yi);
n = size (xi, 1);

%% Compute the mean square error of the leave-one-out prediction

[K, P] = stk_make_matcov (model, xi);
q = size (P, 2);
simple_kriging = (q == 0);

% If simple kriging, just compute the inverse covariance matrix
if simple_kriging
    R = inv (K);
else
    % Use a more complex formula ("virtual cross-validation")
    P_K = P' / K;
    R = K \ (eye (size (K)) - P * ((P_K * P) \ P_K));
    % I = inv (K);
    % R = I - I * P * (inv (P' * I * P)) * P' * I;
end
dR = diag (R);  % The diagonal of the LOO matrix

% Mean
delta_res = R * yi;
raw_res   = delta_res ./ dR;
lp = delta_res' * raw_res / n;

%% Compute gradient

if nargout >= 2
    
    % Get numerical parameter vector from parameter object
    cov_param = stk_get_optimizable_parameters (model.param);
    nb_cov_param = length (cov_param);
    dlp_cov_param = zeros (nb_cov_param, 1);
    
    for diff = 1:nb_cov_param,
        V = feval (model.covariance_type, model.param, xi, xi, diff);
        W = R * V * R;
        dlp_cov_param(diff) = (delta_res'./(n * dR')) * (diag(W) .* raw_res - 2 * W * yi);
    end
    
    if nargout >= 3
        % Extract lnv parameters, if we need them
        if stk_isnoisy (model)
            if isnumeric (model.lognoisevariance)
                if isscalar (model.lognoisevariance)
                    % Homoscedastic case
                    noisevar_nbparam = 1;
                else
                    % Old-style heteroscedastic case: don't optimize
                    noisevar_nbparam = 0;
                end
            else
                % model.lognoisevariance is a parameter object
                noisevar_param = stk_get_optimizable_parameters (model.lognoisevariance);
                noisevar_nbparam = length (noisevar_param);
            end
        else
            noisevar_nbparam = 0;
        end
        
        % NOTE/JB: Minor compatibility-breaking change here, we're returning |]
        % instead of NaN is drl_noise_param is requested for a noiseless model
        % FIXME: If we keep this, advertise in the NEWS file when we merge
        
        dlp_noise_param = zeros (noisevar_nbparam, 1);
        
        for diff = 1:noisevar_nbparam,
            V = stk_noisecov (n, model.lognoisevariance, diff);
            W = R * V * R;
            dlp_noise_param(diff) = (2 * raw_res'./(n * dR')) * (diag(W) .* raw_res - W * yi);
        end
        
    end
    
end

end % function



%!shared f, xi, zi, NI, model, J, dJ1, dJ2
%!
%! f = @(x)(- (0.8 * x(:, 1) + sin (5 * x(:, 2) + 1) ...
%!          + 0.1 * sin (10 * x(:, 3))));
%! DIM = 3;  NI = 20;  box = repmat ([-1.0; 1.0], 1, DIM);
%! xi = stk_sampling_halton_rr2 (NI, DIM, box);
%! zi = stk_feval (f, xi);
%!
%! SIGMA2 = 1.0;  % variance parameter
%! NU     = 4.0;  % regularity parameter
%! RHO1   = 0.4;  % scale (range) parameter
%!
%! model = stk_model('stk_materncov_aniso', DIM);
%! model.param = log([SIGMA2; NU; 1/RHO1 * ones(DIM, 1)]);

%!error [J, dJ1, dJ2] = stk_param_loopvc ();
%!error [J, dJ1, dJ2] = stk_param_loopvc (model);
%!error [J, dJ1, dJ2] = stk_param_loopvc (model, xi);
%!test  [J, dJ1, dJ2] = stk_param_loopvc (model, xi, zi);

%!test
%! loo_pred = stk_predict_leaveoneout(model, xi, zi);
%! J_ref = mean( (loo_pred.mean - zi).^2./(loo_pred.var + exp(model.lognoisevariance)) );
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (J, J_ref));
%! assert (stk_isequal_tolrel (dJ1, [-0.4205 -0.0077 -0.0046 -0.0459 0.2695]', TOL_REL));
%! assert (isempty (dJ2));

%!test  % with noise variance
%! model.lognoisevariance = 2*log(0.1);
%!
%! [J, dJ1, dJ2] = stk_param_loopvc (model, xi, zi);
%! loo_pred = stk_predict_leaveoneout(model, xi, zi);
%! J_ref = mean( (loo_pred.mean - zi).^2./(loo_pred.var + exp(model.lognoisevariance)) );
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (J, J_ref));
%! assert (stk_isequal_tolrel (dJ1, [-0.4147 -0.0077 -0.0045 -0.0450 0.2659]', TOL_REL));
%! assert (stk_isequal_tolrel (dJ2, 1.7417e-03, TOL_REL));

%!shared xi, zi, model, TOL_REL
%! xi = [-1 -.6 -.2 .2 .6 1]';
%! zi = [-0.11 1.30 0.23 -1.14 0.36 -0.37]';
%! model = stk_model ('stk_materncov_iso');
%! model.param = log ([1.0 4.0 2.5]);
%! model.lognoisevariance = log (0.01);
%! TOL_REL = 0.01;

%!test  % Another simple 1D check
%! [LOOPVC, dLOOPVC_dtheta, dLOOPVC_dLNV] = stk_param_loopvc (model, xi, zi);
%! assert (stk_isequal_tolrel (LOOPVC, 0.9643, TOL_REL));
%! assert (stk_isequal_tolrel (dLOOPVC_dtheta, [-0.9488 0.0416 -1.2490]', TOL_REL));
%! assert (stk_isequal_tolrel (dLOOPVC_dLNV, -3.4661e-04, TOL_REL));

%!test  % Same 1D test with simple kriging
%! model.lm = stk_lm_null;
%! [LOOPVC, dLOOPVC_dtheta, dLOOPVC_dLNV] = stk_param_loopvc (model, xi, zi);
%! assert (stk_isequal_tolrel (LOOPVC, 0.8950, TOL_REL));
%! assert (stk_isequal_tolrel (dLOOPVC_dtheta, [-0.8798 0.0455 -1.3190]', TOL_REL));
%! assert (stk_isequal_tolrel (dLOOPVC_dLNV, -1.3801e-03, TOL_REL));

%!test  % Check the gradient on a 2D test case
%!
%! f = @stk_testfun_braninhoo;
%! DIM = 2;
%! BOX = [[-5; 10], [0; 15]];
%! NI = 20;
%! TOL_REL = 1e-2;
%! DELTA = 1e-6;
%!
%! model = stk_model ('stk_materncov52_iso', DIM);
%! xi = stk_sampling_halton_rr2 (NI, DIM, BOX);
%! zi = stk_feval (f, xi);
%!
%! model.param = [1 1];
%! [r1, dr] = stk_param_loopvc (model, xi, zi);
%!
%! model.param = model.param + DELTA * [0 1];
%! r2 = stk_param_loopvc (model, xi, zi);
%!
%! assert (stk_isequal_tolrel (dr(2), (r2 - r1) / DELTA, TOL_REL));
