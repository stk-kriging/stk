% STK_PARAM_RELIK computes the restricted likelihood of a model given data.
%
% CALL: [ARL, dARL_dtheta, dARL_dLNV] = stk_param_relik (MODEL)
%
%   computes the opposite of the restricted likelihood (denoted by ARL for
%   Anti-Restricted Likelihood) of MODEL given the data. The function also
%   returns the gradient dARL_dtheta of ARL with respect to the parameters
%   of the covariance function and the derivative dARL_dLNV of ARL with
%   respect to the logarithm of the noise variance.
%
% EXAMPLE: see paramestim/stk_param_estim.m

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function [rl, drl_param, drl_lnv] = stk_param_relik (model)

if nargin > 1,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% % Ensure that param is a column vector (note: in the case where model.param is 
% % an object, this is actually a call to subsasgn() in disguise).
% param = model.param(:);

NOISYOBS   = ~isa(model.noise.cov, 'stk_nullcov');
PARAMPRIOR = isa(model.randomprocess.priorcov, 'stk_bayescov');
NOISEPRIOR = isa(model.noise.cov, 'stk_bayescov');

if NOISYOBS,
    if (nargout == 3) && ~isa(model.noise.cov, 'stk_homnoisecov')
        error(['In order to estimate the variance of the observation noise' ...
            'please set model.noise.cov to an object of class stk_homnoisecov.']);
    end
else
    if NOISEPRIOR,
        error(['Do not set a prior on the noise variance when there is' ...
            'no observation noise']);
    end
    % adding a small observation noise helps
    NOISYOBS = true;
    model.noise.cov = stk_homnoisecov(100 * eps);
end

n = model.observations.n;

yi = model.observations.z;


%% compute rl

[K, P] = stk_make_matcov(model);
q = size(P, 2);

[Q, R_ignored] = qr(P); %#ok<NASGU> %the second argument *must* be here
W = Q(:, (q+1):n);
G = W' * (K * W);

% Cholesky factorization: G = C' * C, with upper-triangular C
C = stk_cholcov (G);

% Compute log (det (G)) using the Cholesky factor
ldetWKW = 2 * sum (log (diag (C)));

% Compute (W' yi)' * G^(-1) * (W' yi) as u' * u, with u = C' \ (W' * yi)
u = linsolve (C, W' * double(yi), struct ('UT', true, 'TRANSA', true));
attache = sum (u .^ 2);

priorcov = model.randomprocess.priorcov; % GP prior

rl = 0.5 * ((n-q) * log(2*pi) + ldetWKW + attache);

% regularization (prior) terms
if PARAMPRIOR, rl = rl - priorcov.logpdf; end
if NOISEPRIOR, rl = rl - model.noise.cov.logpdf; end

%% compute gradient

if nargout >= 2
    
    drl_param = zeros (length (priorcov.cparam), 1);
    
    F = linsolve (C, W', struct ('UT', true, 'TRANSA', true));
    H = F' * F;
    z = H * double (yi);

    for diff = 1:size(drl_param, 1),
        V = priorcov(model.observations.x, model.observations.x, diff);
        drl_param(diff) = 1/2 * (sum (sum (H .* V)) - z' * V * z);
    end
    
    if PARAMPRIOR
        drl_param = drl_param - priorcov.logpdfgrad;
    end
    
    if nargout >= 3,
        if NOISYOBS,
            diff = 1;
            V = feval(model.noise.cov, model.observations.x, [], diff);
            drl_lnv = 1/2 * (sum (sum (H .* V)) - z' * V * z);
            if NOISEPRIOR
                drl_lnv = drl_lnv - model.noise.logpdfgrad;
            end
        else
            % returns NaN for the derivative with respect to the noise
            % variance in the case of a model without observation noise
            drl_lnv = NaN;
        end
    end
    
end

end % function stk_param_relik


%!shared f, xi, zi, NI, model, J, dJ1, dJ2
%!
%! f = @(x)( -(0.8*x(1)+sin(5*x(2)+1)+0.1*sin(10*x(3))) );
%! DIM = 3; NI = 20; box = repmat([-1.0; 1.0], 1, DIM);
%! xi = stk_sampling_halton_rr2 (NI, DIM, box);
%! zi = stk_feval(f, xi);
%!
%! SIGMA2 = 1.0;  % variance parameter
%! NU     = 4.0;  % regularity parameter
%! RHO1   = 0.4;  % scale (range) parameter
%!
%! model = stk_model('stk_materncov_aniso');
%! model = stk_setobs(model, xi, zi);
%! model.randomprocess.priorcov.param = log([SIGMA2; NU; 1/RHO1 * ones(DIM, 1)]);

%!error [J, dJ1, dJ2] = stk_param_relik ();
%!test  [J, dJ1, dJ2] = stk_param_relik (model);
%!error [J, dJ1, dJ2] = stk_param_relik (model, pi^2);

%!test  % Another simple 1D check
%!
%! xi = [-1 -.6 -.2 .2 .6 1]';
%! zi = [-0.11 1.30 0.23 -1.14 0.36 -0.37]';
%!
%! model = stk_model ('stk_materncov_iso');
%! model = stk_setobs(model, xi, zi);
%! model.randomprocess.priorcov.param = log([1.0 4.0 2.5]);
%! model.noise.cov = stk_homnoisecov (0.01);
%! [ARL, dARL_dtheta, dARL_dLNV] = stk_param_relik (model);
%!
%! TOL_REL = 0.01;
%! assert (stk_isequal_tolrel (ARL, 6.327, TOL_REL));
%! assert (stk_isequal_tolrel (dARL_dtheta, [0.268 0.0149 -0.636]', TOL_REL));
%! assert (stk_isequal_tolrel (dARL_dLNV, -1.581e-04, TOL_REL));

