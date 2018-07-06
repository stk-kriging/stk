% STK_PARAM_LOOMSE computes the Leave-One-Out criterion of a model given data
%
% CALL: [C, COVPARAM_DIFF, LNV_DIFF] = stk_param_loomse (MODEL, XI, YI)
%
%   computes the value C of the leave-one-out mean square error criterion for
%   the MODEL given the data (XI, YI).
%
% CALL: [C, COVPARAM_DIFF, LNV_DIFF] = stk_param_loomse (MODEL, XI, YI)
%
%   also returns the gradient COVPARAM_DIFF of C with respect to the parameters
%   of the covariance function, and its derivative LNV_DIFF with respect to the
%   logarithm of the noise variance.
%
% REFERENCE
%
%   [1] Francois Bachoc. Estimation parametrique de la fonction de covariance
%       dans le modele de krigeage par processus gaussiens: application a la
%       quantification des incertitudes en simulation numerique.
%       PhD thesis, Paris 7, 2013. http://www.theses.fr/2013PA077111
%
% See also: stk_predict_leaveoneout, stk_param_relik

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%    Copyright (C) 2018 LNE
%
%    Author:  Remi Stroh  <remi.stroh@lne.fr>

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

function [C, covparam_diff, lnv_diff] = stk_param_loomse (model, xi, yi)

yi = double (yi);
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
raw_res = (R * yi) ./ dR;  % Compute "raw" residuals
C = raw_res' * raw_res / n;


%% Compute gradient

if nargout >= 2
    
    % Get numerical parameter vector from parameter object
    cov_param = stk_get_optimizable_parameters (model.param);
    nb_cov_param = length (cov_param);
    covparam_diff = zeros (nb_cov_param, 1);
    
    for diff = 1:nb_cov_param
        V = feval (model.covariance_type, model.param, xi, xi, diff);
        W = R * V * R;
        covparam_diff(diff) = (2 * raw_res'./(n * dR')) * (diag(W) .* raw_res - W * yi);
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
        
        if noisevar_nbparam == 0
            
            lnv_diff = [];
            
        else
            
            lnv_diff = zeros (noisevar_nbparam, 1);
            
            for diff = 1:noisevar_nbparam
                V = stk_noisecov (n, model.lognoisevariance, diff);
                W = R * V * R;
                lnv_diff(diff) = (2 * raw_res'./(n * dR')) * (diag(W) .* raw_res - W * yi);
            end
            
        end
    end
    
end

end % function


%!shared f, xi, zi, NI, model, C, dC1, dC2
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

%!error [C, dC1, dC2] = stk_param_loomse ();
%!error [C, dC1, dC2] = stk_param_loomse (model);
%!error [C, dC1, dC2] = stk_param_loomse (model, xi);
%!test  [C, dC1, dC2] = stk_param_loomse (model, xi, zi);

%!test
%! loo_pred = stk_predict_leaveoneout (model, xi, zi);
%! C_ref = mean ((loo_pred.mean - zi) .^ 2);
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (C, C_ref));
%! assert (abs (dC1(1)) < sqrt (eps))
%! assert (stk_isequal_tolrel (dC1(2:end), [-0.0091 0.0167 -0.0277 0.3326]', TOL_REL));
%! assert (isequal (dC2, []));

%!test  % with noise variance
%! model.lognoisevariance = 2*log(0.1);
%!
%! [C, dC1, dC2] = stk_param_loomse (model, xi, zi);
%! loo_pred = stk_predict_leaveoneout (model, xi, zi);
%! C_ref = mean ((loo_pred.mean - zi) .^ 2);
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (C, C_ref));
%! assert (stk_isequal_tolrel (dC1, [-1.7417e-03  -9.1600e-03 0.0166 -0.0275 0.3309]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2,  1.7417e-03, TOL_REL));

%!shared xi, zi, model, TOL_REL
%! xi = [-1 -.6 -.2 .2 .6 1]';
%! zi = [-0.11 1.30 0.23 -1.14 0.36 -0.37]';
%! model = stk_model ('stk_materncov_iso');
%! model.param = log ([1.0 4.0 2.5]);
%! model.lognoisevariance = log (0.01);
%! TOL_REL = 0.01;

%!test  % Another simple 1D check
%! [C, dC1, dC2] = stk_param_loomse (model, xi, zi);
%! assert (stk_isequal_tolrel (C, 0.84, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [3.4661e-04 -9.2237e-03 -0.1838]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2, -3.4661e-04, TOL_REL));

%!test  % Same 1D test with simple kriging
%! model.lm = stk_lm_null;
%! [C, dC1, dC2] = stk_param_loomse (model, xi, zi);
%! assert (stk_isequal_tolrel (C, 0.7189, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [1.3801e-03 5.1088e-04 -0.3730]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2, -1.3801e-03, TOL_REL));

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
%! [C1, dC] = stk_param_loomse (model, xi, zi);
%!
%! model.param = model.param + DELTA * [0 1];
%! C2 = stk_param_loomse (model, xi, zi);
%!
%! assert (stk_isequal_tolrel (dC(2), (C2 - C1) / DELTA, TOL_REL));

%!test  % Check invariance by sigma
%!
%! C1 = stk_param_loomse (model, xi, zi);
%!
%! model.param(1) = model.param(1) + 5;
%!
%! C2 = stk_param_loomse (model, xi, zi);
%! assert (stk_isequal_tolrel (C1, C2))
