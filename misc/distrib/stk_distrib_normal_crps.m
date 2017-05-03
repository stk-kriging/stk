% STK_DISTRIB_NORMAL_CRPS computes the CRPS for Gaussian density prediction.
%
% CALL: CRPS = stk_distrib_normal_crps (Z, MU, SIGMA)
%
%   computes the Continuous Ranked Probability Score (CRPS) in case of
%   Gaussian density prediction. It is equal to the integral of Brier Score:
%       CRPS = int_{-inf}^{+inf} [Phi((y - MU)/SIGMA) - u(y - Z)]^2 dy,
%   where Phi is the cumulative distribution function (cdf) of the normal
%   distribution, and u is the Heaviside step function.
%   Equivalent of Mean Square Error (MSE), but for density prediction.
%   CRPS equals to 0 means perfect predictive distribution (mu = z and
%   sigma = 0).
%
% The formula works only on Gaussian posterior assumption.
%   * z: a set of observations, to compare with predictions;
%   * mu: a posterior predictions on the same observations points;
%   * sigma: posterior standard deviations of the predictions.
%
% CALL: CRPS = stk_distrib_normal_crps (Z, MU, SIGMA, NOISTD)
%
%   computes the CRPS, supposing that the points are observed with a
%   Gaussian noise with a known standard deviation 'noistd'. It is equal to
%       CRPS = int_{-inf}^{+inf} [Phi((y - MU)/SIGMA) - Phi((y - Z)/NOISTD)]^2 dy.
%
%   CRPS equals to zero if and only if mu == z and sigma == noistd. The
%   result is always positive or zero.
%
% EXAMPLE:
%
%   ni = 4; nt = 20; dim = 1;
%   f = @(x)( stk_testfun_twobumps (x) );
%   % Observations
%   xi = sort (stk_sampling_randomlhs (ni, dim));
%   zi = f (xi);
%   % Test points
%   xt = sort (stk_sampling_randunif (nt, dim));
%   zt = f (xt);
%   % Model
%   model = stk_model (@stk_materncov52_aniso, dim);
%   model.param = [2*log(1.0); -log(0.6)];
%   zp = stk_predict (model, xi, zi, [xi; xt]);
%   % Comparison
%   crps = stk_distrib_normal_crps ([zi; zt], zp.mean, sqrt(zp.var));
%
%   % With noise
%   noistd = 0.5;
%   zin = zi + noistd*randn ( size(zi) );	% Noised observations
%   ztn = zt + noistd*randn ( size(zt) );
%   model.lognoisevariance = 2*log(0.7);
%   zpn = stk_predict (model, xi, zin, [xi; xt]);
%   zpn_var_obs = zpn.var + exp(model.lognoisevariance);
%
%   % Compare noised observations with prediction of the model
%   crps_obs = stk_distrib_normal_crps ([zin; ztn], zpn.mean, sqrt(zpn_var_obs));
%
%   % Compare the real function with the prediction of the latent process
%   crps_func = stk_distrib_normal_crps ([zi; zt], zpn.mean, sqrt(zpn.var));
%
%   % Compare (Gaussian) prediction density with real (Gaussian) density
%   crps_dens = stk_distrib_normal_crps ([zi; zt], zpn.mean, sqrt(zpn_var_obs), noistd);
%
% REFERENCE
%
%   [1] Tilmann Gneiting and Afrian E.Raftery, "Strictly proper scoring
%       rules, prediction, and estimation", Journal of the American
%       Statistical Association, 102(477):359-378, 2007.
%
% See also: stk_distrib_normal_cdf, stk_predict_leaveoneout

% Copyright Notice
%
%    Copyright (C) 2017 LNE
%    Copyright (C) 2017 CentraleSupelec
%
%    Authors:  Julien Bect     <julien.bect@centralesupelec.fr>
%              Romain Benassi  <romain.benassi@gmail.com>
%              Remi Stroh      <remi.stroh@lne.fr>

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

function crps = stk_distrib_normal_crps(z, mu, sigma, noistd)

if nargin > 4
    stk_error('Too many inputs arguments.', 'TooManyInputArgs');
end

%% Center and reduce the data
if nargin > 1 && ~isempty(mu)
    delta = bsxfun (@minus, z, mu); % compute z - m
else
    % Default: mu = 0;
    delta = z;
end

if nargin > 2 && ~isempty(sigma)
    sigma(sigma < 0) = nan;
else
    % Default: sigma = 1
    sigma = 1;
end

if nargin > 3 && ~isempty(noistd)
    noistd(noistd < 0) = nan;
else
    % Default: noistd = 0
    noistd = 0;
end

% Check size
[delta, sigma, noistd] = stk_commonsize (delta, sigma, noistd);


%% Formula for CRPS
crps = nan (size (delta));

sig_tot = sqrt(sigma.^2 + noistd.^2);
b0 = ~ (isnan (delta) | isnan (sig_tot));
b1 = (sig_tot > 0);

% Compute the CRPS where sig_tot > 0
b = b0 & b1;
if any (b)
    u = delta(b) ./ sig_tot(b);       % (z - m)/sqrt(s^2 + n^2)
    crps(b) = sig_tot(b).*(2*stk_distrib_normal_pdf (u)...
        + u.*(2*stk_distrib_normal_cdf (u) - 1) )...
        - (sigma (b) + noistd (b))/sqrt(pi);
end

% Compute the CRPS where sig_tot == 0: CRPS = abs(z - mu)
b = b0 & (~ b1);
crps(b) =  abs(delta(b));

% Correct numerical inaccuracies
crps(crps < 0) = 0;
end

% Check particular values

%!assert (stk_isequal_tolabs (stk_distrib_normal_crps (0.0, 0.0, 0.0), 0.0))
%!assert (stk_isequal_tolabs (stk_distrib_normal_crps (0.0, 0.0, 1.0), (sqrt(2) - 1)/sqrt(pi)))
%!assert (stk_isequal_tolabs (stk_distrib_normal_crps (0.0, 0.0, 1.0, 1.0), 0.0))

% Compute CRPS in two cases (noiseless and noised case)

%!shared n, x_obs, mu, sigma, noistd, crps, crps_noise, crps_exp, crps_noise_exp, c
%! n = 10;
%! x_obs = 2*randn(n, 1);       % random observations
%! mu = 5*(rand(n, 1) - 0.5);	% random values of mean
%! sigma = 10*rand(n, 1);       % random values of standard deviation
%! noistd = 1 + 7*rand(n, 1);	% random values of standard deviation of noise
%! crps = stk_distrib_normal_crps(x_obs, mu, sigma);
%! crps_noise = stk_distrib_normal_crps(x_obs, mu, sigma, noistd);

% Check that outputs have good properties

%!assert (isequal (size (crps), size(crps_noise), [n, 1]))
%!assert (all ([crps(:); crps_noise(:)] >= 0))
%!assert (stk_isequal_tolabs (crps, stk_distrib_normal_crps(mu, x_obs, sigma)))
%!assert (stk_isequal_tolabs (crps_noise, stk_distrib_normal_crps(x_obs, mu, noistd, sigma)))
%!assert (stk_isequal_tolabs (stk_distrib_normal_crps(x_obs, x_obs, noistd, noistd), zeros(n, 1)))

%!assert (stk_isequal_tolabs(stk_distrib_normal_crps(x_obs, mu, 0), abs(x_obs - mu)))
%! c = 2/sqrt(pi)*(sqrt( (sigma.^2 + noistd.^2)/2) - (sigma + noistd)/2);
%!assert (stk_isequal_tolabs(stk_distrib_normal_crps(0, 0, sigma, noistd), c))

% Compare real values (with integrals) and theoretical values (formulas)

%! crps_exp       = NaN(n, 1);
%! crps_noise_exp = NaN(n, 1);
%! if isoctave  % Find the integral function
%!  intfun = @quad;
%! else
%!  intfun = @integral;
%! end
%! for k = 1:n
%!  Freal = @(x)(stk_distrib_normal_cdf(x, x_obs(k), noistd(k)));
%!  Fpred = @(x)(stk_distrib_normal_cdf(x, mu(k), sigma(k)));
%
%!  crps_exp_1 = intfun(@(x)(     Fpred(x) .^2), -Inf, x_obs(k) );
%!  crps_exp_2 = intfun(@(x)((1 - Fpred(x)).^2), x_obs(k), +Inf );
%!  crps_exp(k) = crps_exp_1 + crps_exp_2;
%
%!  crps_noise_exp(k) = intfun(@(x)((Freal(x) - Fpred(x)).^2), -Inf, +Inf);
%! end
%!assert (stk_isequal_tolabs(crps_exp, crps));
%!assert (stk_isequal_tolabs(crps_noise_exp, crps_noise));
