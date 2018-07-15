% STK_PARAM_LOOPVC computes a Leave-One-Out criterion of a model given data
%
% CALL: C = stk_param_loopvc (MODEL, XI, ZI)
%
%   computes the value C of the Leave-One-Out predictive variance criterion of
%   MODEL given the data (XI, ZI).
%
% CALL: [C, COVPARAM_DIFF, LNV_DIFF] = stk_param_loopvc (MODEL, XI, ZI)
%
%   also returns the gradient COVPARAM_DIFF of C with respect to the parameters
%   of the covariance function, its the derivative LNV_DIFF with respect to the
%   logarithm of the noise variance.
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
%    Authors:  Remi Stroh   <remi.stroh@lne.fr>
%              Julien Bect  <julien.bect@centralesupelec.fr>

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

function [C, covparam_diff, noiseparam_diff] = stk_param_loopvc (model, xi, zi)

zi = double (zi);

% Check the size of zi
n = size (xi, 1);
if ~ isequal (size (zi), [n 1])
    stk_error (['zi must be a column vector, with the same' ...
        'same number of rows as x_obs.'], 'IncorrectSize');
end

if nargout >= 3
    % Parameters of the noise variance function
    noiseparam = stk_get_optimizable_noise_parameters (model);
    noiseparam_size = length (noiseparam);
end


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
delta_res = R * zi;
raw_res   = delta_res ./ dR;
C = delta_res' * raw_res / n;


%% Compute gradient

if nargout >= 2
    
    % Get numerical parameter vector from parameter object
    covparam = stk_get_optimizable_parameters (model.param);
    covparam_size = length (covparam);
    covparam_diff = zeros (covparam_size, 1);
    
    for diff = 1:covparam_size
        V = feval (model.covariance_type, model.param, xi, xi, diff);
        W = R * V * R;
        covparam_diff(diff) = (delta_res'./(n * dR')) * (diag(W) .* raw_res - 2 * W * zi);
    end
    
    if nargout >= 3
        
        if noiseparam_size == 0
            noiseparam_diff = [];
        else
            noiseparam_diff = zeros (noiseparam_size, 1);
            for diff = 1:noiseparam_size
                V = stk_covmat_noise (model, xi, [], diff);
                W = R * V * R;
                noiseparam_diff(diff) = (2 * raw_res'./(n * dR')) * (diag(W) .* raw_res - W * zi);
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
%! model = stk_model ('stk_materncov_aniso', DIM);
%! model.param = log ([SIGMA2; NU; 1/RHO1 * ones(DIM, 1)]);

%!error [C, dC1, dC2] = stk_param_loopvc ();
%!error [C, dC1, dC2] = stk_param_loopvc (model);
%!error [C, dC1, dC2] = stk_param_loopvc (model, xi);
%!test  [C, dC1, dC2] = stk_param_loopvc (model, xi, zi);

%!test
%! loo_pred = stk_predict_leaveoneout (model, xi, zi);
%! C_ref = mean ((loo_pred.mean - zi) .^ 2 ./ (loo_pred.var + exp (model.lognoisevariance)));
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (C, C_ref));
%! assert (stk_isequal_tolrel (dC1, [-0.4205 -0.0077 -0.0046 -0.0459 0.2695]', TOL_REL));
%! assert (isequal (dC2, []));

%!test  % with noise variance
%! model.lognoisevariance = 2*log(0.1);
%!
%! [C, dC1, dC2] = stk_param_loopvc (model, xi, zi);
%! loo_pred = stk_predict_leaveoneout (model, xi, zi);
%! C_ref = mean ((loo_pred.mean - zi) .^ 2 ./ (loo_pred.var + exp(model.lognoisevariance)));
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (C, C_ref));
%! assert (stk_isequal_tolrel (dC1, [-0.4147 -0.0077 -0.0045 -0.0450 0.2659]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2, 1.7417e-03, TOL_REL));

%!shared xi, zi, model, TOL_REL
%! xi = [-1 -.6 -.2 .2 .6 1]';
%! zi = [-0.11 1.30 0.23 -1.14 0.36 -0.37]';
%! model = stk_model ('stk_materncov_iso');
%! model.param = log ([1.0 4.0 2.5]);
%! model.lognoisevariance = log (0.01);
%! TOL_REL = 0.01;

%!test  % Another simple 1D check
%! [C, dC1, dC2] = stk_param_loopvc (model, xi, zi);
%! assert (stk_isequal_tolrel (C, 0.9643, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [-0.9488 0.0416 -1.2490]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2, -3.4661e-04, TOL_REL));

%!test  % Same 1D test with simple kriging
%! model.lm = stk_lm_null;
%! [C, dC1, dC2] = stk_param_loopvc (model, xi, zi);
%! assert (stk_isequal_tolrel (C, 0.8950, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [-0.8798 0.0455 -1.3190]', TOL_REL));
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
%! [C1, dC] = stk_param_loopvc (model, xi, zi);
%!
%! model.param = model.param + DELTA * [0 1];
%! C2 = stk_param_loopvc (model, xi, zi);
%!
%! assert (stk_isequal_tolrel (dC(2), (C2 - C1) / DELTA, TOL_REL));
