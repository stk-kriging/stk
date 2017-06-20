% STK_DISTRIB_NORMAL_CRPS computes the CRPS for Gaussian predictive distributions
%
% CALL: CRPS = stk_distrib_normal_crps (Z, MU, SIGMA)
%
%    computes the Continuous Ranked Probability Score (CRPS) of Z with respect
%    to a Gaussian predictive distribution with mean MU and standard deviation
%    SIGMA.
%
%    The CRPS is defined as the integral of the Brier score for the event
%    {Z <= z}, when z ranges from -inf to +inf:
%
%       CRPS = int_{-inf}^{+inf} [Phi((z - MU)/SIGMA) - u(z - Z)]^2 dz,
%
%    where Phi is the normal cdf and u the Heaviside step function.  The CRPS
%    is equal if, and only if, the predictive distribution is a Dirac
%    distribution (SIGMA = 0) and the observed value is equal to the predicted
%    value (Z = MU).
%
% REFERENCE
%
%   [1] Tilmann Gneiting and Adrian E. Raftery, "Strictly proper scoring
%       rules, prediction, and estimation", Journal of the American
%       Statistical Association, 102(477):359-378, 2007.
%
% See also: stk_distrib_normal_cdf, stk_predict_leaveoneout

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec & LNE
%
%    Authors:  Remi Stroh      <remi.stroh@lne.fr>
%              Julien Bect     <julien.bect@centralesupelec.fr>

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

function crps = stk_distrib_normal_crps(z, mu, sigma)

if nargin > 4
    stk_error('Too many inputs arguments.', 'TooManyInputArgs');
end


%% Center and reduce the data

if nargin > 1 && ~ isempty (mu)
    delta = bsxfun (@minus, z, mu); % compute z - m
else
    % Default: mu = 0;
    delta = z;
end

if nargin > 2 && ~ isempty (sigma)
    sigma(sigma < 0) = nan;
else
    % Default: sigma = 1
    sigma = 1;
end

% Check size
[delta, sigma] = stk_commonsize (delta, sigma);


%% Formula for CRPS

crps = nan (size (delta));

b0 = ~ (isnan (delta) | isnan (sigma));
b1 = (sigma > 0);

% Compute the CRPS where sigma > 0
b = b0 & b1;
if any (b)
    u = delta(b) ./ sigma(b);  % (z - m)/s
    crps(b) = sigma(b) .* (2 * stk_distrib_normal_pdf (u)...
        + u .* (2 * stk_distrib_normal_cdf (u) - 1)) - sigma(b) / (sqrt (pi));
end

% Compute the CRPS where sigma == 0: CRPS = abs(z - mu)
b = b0 & (~ b1);
crps(b) =  abs (delta(b));

% Correct numerical inaccuracies
crps(crps < 0) = 0;

end


% Check particular values

%!assert (stk_isequal_tolabs (stk_distrib_normal_crps (0.0, 0.0, 0.0), 0.0))
%!assert (stk_isequal_tolabs (stk_distrib_normal_crps (0.0, 0.0, 1.0), (sqrt(2) - 1)/sqrt(pi)))

% Compute CRPS in two cases (noiseless and noised case)

%!shared n, x_obs, mu, sigma, crps, crps_exp
%! n = 10;
%! x_obs = 2 * randn (n, 1);      % random observations
%! mu = 5 * (rand(n, 1) - 0.5);   % random values of mean
%! sigma = 10 * rand (n, 1);      % random values of standard deviation
%! crps = stk_distrib_normal_crps (x_obs, mu, sigma);

% Check that outputs have good properties

%!assert (isequal (size (crps), [n, 1]))
%!assert (all (crps >= 0))
%!assert (stk_isequal_tolabs (crps, stk_distrib_normal_crps(mu, x_obs, sigma)))

%!assert (stk_isequal_tolabs (stk_distrib_normal_crps (x_obs, mu, 0), abs (x_obs - mu)))

% Compare experimental values (computed with trapezoidal integration)
% and theoretical values (formulas)

%!test
%! crps_exp = nan (n, 1);
%! for k = 1:n
%!  x1 = linspace (mu(k) - 6*sigma(k), x_obs(k), 2e5);
%!  x2 = linspace (x_obs(k), mu(k) + 6*sigma(k), 2e5);
%!  x = [x1, x2];
%
%!  F1 = stk_distrib_normal_cdf (x1, mu(k), sigma(k)).^2;
%!  F2 = stk_distrib_normal_cdf (mu(k), x2, sigma(k)).^2;
%!  F = [F1, F2];
%
%!  crps_exp(k) = trapz (x, F);
%! end

%!assert (stk_isequal_tolabs (crps_exp, crps));
