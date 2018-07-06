% STK_PARAM_RELIK computes the restricted likelihood of a model given data
%
% CALL: C = stk_param_relik (MODEL, XI, YI)
%
%   computes the value C of the opposite of the restricted likelihood criterion
%   for the MODEL given the data (XI, YI).
%
% CALL: [C, COVPARAM_DIFF, LNV_DIFF] = stk_param_relik (MODEL, XI, YI)
%
%   also returns the gradient COVPARAM_DIFF of C with respect to the parameters
%   of the covariance function, and its derivative LNV_DIFF of C with respect to
%   the logarithm of the noise variance.
%
% EXAMPLE: see paramestim/stk_param_estim.m

% Copyright Notice
%
%    Copyright (C) 2015, 2016, 2018 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function [C, covparam_diff, lnv_diff] = stk_param_relik (model, xi, yi)

% Get numerical parameter vector from parameter object
paramvec = stk_get_optimizable_parameters (model.param);

PARAMPRIOR = isfield (model, 'prior');
NOISEPRIOR = isfield (model, 'noiseprior');

% Make sure that lognoisevariance is -inf for noiseless models
noiseless = ~ stk_isnoisy (model);
if noiseless
    model.lognoisevariance = -inf;
end

n = size (xi, 1);


%% Compute the (opposite of) the restricted log-likelihood

[K, P] = stk_covmat_response (model, xi);
q = size (P, 2);
simple_kriging = (q == 0);

% Choleski factorization: K = U' * U, with upper-triangular U
[U, epsi] = stk_cholcov (K);
if noiseless && (epsi > 0)
    stk_assert_no_duplicates (xi);
end

if ~ simple_kriging
    
    % Construct a "filtering matrix" A = W'
    [Q, R_ignored] = qr (P);  %#ok<NASGU> %the second argument *must* be here
    W = Q(:, (q+1):n);
    
    % Compute G = W' * K * W, the covariance matrix of filtered observations
    M = U * W;
    G = (M') * M;
    
    % Check if G is (at least close to) symmetric
    Delta = G - G';  s = sqrt (diag (G));
    if any (abs (Delta) > eps * (s * s'))
        warning ('STK:stk_param_relik:NumericalAccuracyProblem', ...
            'The computation of G = W'' * K * W is inaccurate.');
        G = 0.5 * (G + G');  % Make it at least symmetric
    end
    
    % Cholesky factorization: G = U' * U, with upper-triangular U
    U = stk_cholcov (G);
end

% Compute log (det (G)) using the Cholesky factor
ldetWKW = 2 * sum (log (diag (U)));

% Compute (W' yi)' * G^(-1) * (W' yi) as v' * v, with v = U' \ (W' * yi)
if simple_kriging
    yyi = double (yi);
else
    yyi = W' * double (yi);
end
v = linsolve (U, yyi, struct ('UT', true, 'TRANSA', true));
attache = sum (v .^ 2);

C = 0.5 * ((n - q) * log(2 * pi) + ldetWKW + attache);


%% Add priors

if PARAMPRIOR
    delta_p = paramvec - model.prior.mean;
    C = C + 0.5 * delta_p' * model.prior.invcov * delta_p;
end

if NOISEPRIOR
    delta_lnv = model.lognoisevariance - model.noiseprior.mean;
    C = C + 0.5 * (delta_lnv ^ 2) / model.noiseprior.var;
end


%% Compute gradient

if nargout >= 2
    
    nb_cov_param = length (paramvec);
    covparam_diff = zeros (nb_cov_param, 1);
    
    if exist ('OCTAVE_VERSION', 'builtin') == 5
        % Octave remembers that U is upper-triangular and automatically picks
        % the appropriate algorithm.  Cool.
        if simple_kriging
            F = inv (U');
        else
            F = (U') \ (W');
        end
    else
        % Apparently Matlab does not automatically leverage the fact that U is
        % upper-triangular.  Pity.  We have to call linsolve explicitely, then.
        if simple_kriging
            F = linsolve (U, eye (n), struct ('UT', true, 'TRANSA', true));
        else
            F = linsolve (U, W', struct ('UT', true, 'TRANSA', true));
        end
    end
    H = F' * F;  % = W * G^(-1) * W'
    
    z = H * double (yi);
    
    for diff = 1:nb_cov_param
        V = stk_covmat_gp0 (model, xi, [], diff);
        covparam_diff(diff) = 1/2 * (sum (sum (H .* V)) - z' * V * z);
    end
    
    if PARAMPRIOR
        covparam_diff = covparam_diff + model.prior.invcov * delta_p;
    end
    
    if nargout >= 3
        
        nb_noise_param = 1;  % For now
                
        if noiseless
            lnv_diff = [];
        else
            lnv_diff = zeros (nb_noise_param, 1);
            
            for diff = 1:nb_noise_param
                V = stk_covmat_noise (model, xi, [], diff);
                lnv_diff(diff) = 1/2 * (sum (sum (H .* V)) - z' * V * z);
            end            
        end
        
        % WARNING: this still assumes nb_noise_param == 1
        if NOISEPRIOR
            lnv_diff = lnv_diff + delta_lnv / model.noiseprior.var;
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
%! model = stk_model('stk_materncov_aniso');
%! model.param = log([SIGMA2; NU; 1/RHO1 * ones(DIM, 1)]);

%!error [C, dC1, dC2] = stk_param_relik ();
%!error [C, dC1, dC2] = stk_param_relik (model);
%!error [C, dC1, dC2] = stk_param_relik (model, xi);
%!test  [C, dC1, dC2] = stk_param_relik (model, xi, zi);

%!test
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (C, 21.6, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [4.387 -0.1803 0.7917 0.1392 2.580]', TOL_REL));
%! assert (isequal (dC2, []));

%!shared xi, zi, model, TOL_REL
%! xi = [-1 -.6 -.2 .2 .6 1]';
%! zi = [-0.11 1.30 0.23 -1.14 0.36 -0.37]';
%! model = stk_model ('stk_materncov_iso');
%! model.param = log ([1.0 4.0 2.5]);
%! model.lognoisevariance = log (0.01);
%! TOL_REL = 0.01;

%!test  % Another simple 1D check
%! [C, dC1, dC2] = stk_param_relik (model, xi, zi);
%! assert (stk_isequal_tolrel (C, 6.327, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [0.268 0.0149 -0.636]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2, -1.581e-04, TOL_REL));

%!test  % Same 1D test with simple kriging
%! model.lm = stk_lm_null;
%! [C, dC1, dC2] = stk_param_relik (model, xi, zi);
%! assert (stk_isequal_tolrel (C, 7.475, TOL_REL));
%! assert (stk_isequal_tolrel (dC1, [0.765 0.0238 -1.019]', TOL_REL));
%! assert (stk_isequal_tolrel (dC2, 3.0517e-03, TOL_REL));

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
%! [C1 dC] = stk_param_relik (model, xi, zi);
%!
%! model.param = model.param + DELTA * [0 1];
%! C2 = stk_param_relik (model, xi, zi);
%!
%! assert (stk_isequal_tolrel (dC(2), (C2 - C1) / DELTA, TOL_REL));
    