% STK_PARAM_RELIK computes the restricted likelihood of a model given data
%
% CALL: [ARL, dARL_dtheta, dARL_dLNV] = stk_param_relik (MODEL, XI, YI)
%
%   computes the opposite of the restricted likelihood (denoted by ARL for
%   Anti-Restricted Likelihood) of MODEL given the data (XI, YI). The function
%   also returns the gradient dARL_dtheta of ARL with respect to the parameters
%   of the covariance function and the derivative dARL_dLNV of ARL with respect
%   to the logarithm of the noise variance.
%
% EXAMPLE: see paramestim/stk_param_estim.m

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
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

function [rl, drl_cov_param, drl_noise_param] = stk_param_relik (model, xi, yi)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Get numerical parameter vector from parameter object
cov_param = stk_get_optimizable_parameters (model.param);

PARAMPRIOR = isfield (model, 'prior');
NOISEPRIOR = isfield (model, 'noiseprior');

% Extract lnv parameters, if we need them
if (nargout >= 3) || NOISEPRIOR
    if stk_isnoisy (model)
        if isnumeric (model.lognoisevariance)
            if isscalar (model.lognoisevariance)
                % Homoscedastic case
                noisevar_param = model.lognoisevariance;
                noisevar_nbparam = 1;
            else
                % Old-style heteroscedastic case: don't optimize
                noisevar_param = [];
                noisevar_nbparam = 0;
            end
        else
            % model.lognoisevariance is a parameter object
            noisevar_param = stk_get_optimizable_parameters (model.lognoisevariance);
            noisevar_nbparam = length (noisevar_param);
            % Make sure we have a column vector
            noisevar_param = reshape (noisevar_param, 1, noisevar_nbparam);
        end
    else
        % If NOISEPRIOR is true, this is very likely going to cause an error
        % below, unless the prior is zero-dimensional...  Wait and see...
        noisevar_param = [];
        noisevar_nbparam = 0;
    end
end

n = size (xi, 1);


%% Compute the (opposite of) the restricted log-likelihood

[K, P] = stk_covmat_response (model, xi);
q = size (P, 2);
simple_kriging = (q == 0);

if simple_kriging
    
    G = K;  % No need to filter anything out
    
else
    
    % Construct a "filtering matrix" A = W'
    [Q, R_ignored] = qr (P);  %#ok<NASGU> %the second argument *must* be here
    W = Q(:, (q+1):n);
    
    % Compute G = W' * K * W  (covariance matrix of filtered observations)
    M = (stk_cholcov (K)) * W;
    G = (M') * M;
    
    % Check if G is (at least close to) symmetric
    Delta = G - G';  s = sqrt (diag (G));
    if any (abs (Delta) > eps * (s * s'))
        warning ('STK:stk_param_relik:NumericalAccuracyProblem', ...
            'The computation of G = W'' * K * W is inaccurate.');
        G = 0.5 * (G + G');  % Make it at least symmetric
    end
end

% Cholesky factorization: G = C' * C, with upper-triangular C
C = stk_cholcov (G);

% Compute log (det (G)) using the Cholesky factor
ldetWKW = 2 * sum (log (diag (C)));

% Compute (W' yi)' * G^(-1) * (W' yi) as u' * u, with u = C' \ (W' * yi)
if simple_kriging
    u = linsolve (C, double (yi), struct ('UT', true, 'TRANSA', true));
else
    u = linsolve (C, W' * double (yi), struct ('UT', true, 'TRANSA', true));
end
attache = sum (u .^ 2);

rl = 0.5 * ((n - q) * log(2 * pi) + ldetWKW + attache);


%% Add priors

if PARAMPRIOR
    delta_p = cov_param - model.prior.mean;
    rl = rl + 0.5 * delta_p' * model.prior.invcov * delta_p;
end

if NOISEPRIOR
    delta_lnv = noisevar_param - model.noiseprior.mean;
    if isfield (model.noiseprior, 'invcov')
        rl = rl + 0.5 * (delta_lnv' * model.noiseprior.invcov * delta_lnv);
    else % assume isfield (model.noiseprior, 'var')
        rl = rl + 0.5 * (delta_lnv' * (model.noiseprior.var \ delta_lnv));
    end
end


%% Compute gradient

if nargout >= 2
    
    nb_cov_param = length (cov_param);
    drl_cov_param = zeros (nb_cov_param, 1);
    
    if simple_kriging
        H = inv (G);
    else
        F = linsolve (C, W', struct ('UT', true, 'TRANSA', true));
        H = F' * F;  % = W * G^(-1) * W'
    end
    
    z = H * double (yi);
    
    for diff = 1:nb_cov_param,
        V = stk_covmat_gp0 (model, xi, [], diff);
        drl_cov_param(diff) = 1/2 * (sum (sum (H .* V)) - z' * V * z);
    end
    
    if PARAMPRIOR
        drl_cov_param = drl_cov_param + model.prior.invcov * delta_p;
    end
    
    if nargout >= 3        
        
        % NOTE/JB: Minor compatibility-breaking change here, we're returning |]
        % instead of NaN is drl_noise_param is requested for a noiseless model
        % FIXME: If we keep this, advertise in the NEWS file when we merge
        
        drl_noise_param = zeros (noisevar_nbparam, 1);
            
        for diff = 1:noisevar_nbparam,
            V = stk_covmat_noise (model, xi, [], diff);
            drl_noise_param(diff) = 1/2 * (sum (sum (H .* V)) - z' * V * z);
        end
        
        if NOISEPRIOR
            if isfield (model.noiseprior, 'invcov')
                drl_noise_param = drl_noise_param + model.noiseprior.invcov * delta_lnv;
            else % assume isfield (model.noiseprior, 'var')
                drl_noise_param = drl_noise_param + (model.noiseprior.var\delta_lnv);
            end
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
%! model = stk_model('stk_materncov_aniso');
%! model.param = log([SIGMA2; NU; 1/RHO1 * ones(DIM, 1)]);

%!error [J, dJ1, dJ2] = stk_param_relik ();
%!error [J, dJ1, dJ2] = stk_param_relik (model);
%!error [J, dJ1, dJ2] = stk_param_relik (model, xi);
%!test  [J, dJ1, dJ2] = stk_param_relik (model, xi, zi);
%!error [J, dJ1, dJ2] = stk_param_relik (model, xi, zi, pi);

%!test
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (J, 21.6, TOL_REL));
%! assert (stk_isequal_tolrel (dJ1, [4.387 -0.1803 0.7917 0.1392 2.580]', TOL_REL));
%! assert (isempty (dJ2));

%!shared xi, zi, model, TOL_REL
%! xi = [-1 -.6 -.2 .2 .6 1]';
%! zi = [-0.11 1.30 0.23 -1.14 0.36 -0.37]';
%! model = stk_model ('stk_materncov_iso');
%! model.param = log ([1.0 4.0 2.5]);
%! model.lognoisevariance = log (0.01);
%! TOL_REL = 0.01;

%!test  % Another simple 1D check
%! [ARL, dARL_dtheta, dARL_dLNV] = stk_param_relik (model, xi, zi);
%! assert (stk_isequal_tolrel (ARL, 6.327, TOL_REL));
%! assert (stk_isequal_tolrel (dARL_dtheta, [0.268 0.0149 -0.636]', TOL_REL));
%! assert (stk_isequal_tolrel (dARL_dLNV, -1.581e-04, TOL_REL));

%!test  % Same 1D test with simple kriging
%! model.lm = stk_lm_null;
%! [ARL, dARL_dtheta, dARL_dLNV] = stk_param_relik (model, xi, zi);
%! assert (stk_isequal_tolrel (ARL, 7.475, TOL_REL));
%! assert (stk_isequal_tolrel (dARL_dtheta, [0.765 0.0238 -1.019]', TOL_REL));
%! assert (stk_isequal_tolrel (dARL_dLNV, 3.0517e-03, TOL_REL));

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
%! [r1 dr] = stk_param_relik (model, xi, zi);
%!
%! model.param = model.param + DELTA * [0 1];
%! r2 = stk_param_relik (model, xi, zi);
%!
%! assert (stk_isequal_tolrel (dr(2), (r2 - r1) / DELTA, TOL_REL));
