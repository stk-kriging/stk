% STK_PREDICT performs a kriging prediction from data
%
% CALL: ZP = stk_predict (MODEL, XI, ZI, XP)
%
%    performs a kriging prediction at the points XP, given the observations
%    (XI, ZI) and the prior MODEL. The input arguments XI, ZI, and XP can be
%    either numerical matrices or dataframes. More precisely, on a factor space
%    of dimension DIM,
%
%     * XI must have size NI x DIM,
%     * ZI must have size NI x 1,
%     * XP must have size NP x DIM,
%
%    where NI is the number of observations and NP the number of prediction
%    points. The output ZP is a dataframe of size NP x 2, with:
%
%     * the kriging predictor in the first column (ZP.mean), and
%     * the kriging variance in the second column (ZP.var).
%
%    From a Bayesian point of view, ZP.mean and ZP.var are respectively the
%    posterior mean and variance of the Gaussian process prior MODEL given the
%    data (XI, ZI).  Note that, in the case of noisy data, ZP.var is the
%    (posterior) variance of the latent Gaussian process, not the variance of a
%    future noisy observation at location XP.
%
% CALL: [ZP, LAMBDA, MU] = stk_predict (MODEL, XI, ZI, XP)
%
%    also returns the matrix of kriging weights LAMBDA and the matrix of
%    Lagrange multipliers MU.
%
% CALL: [ZP, LAMBDA, MU, K] = stk_predict (MODEL, XI, ZI, XP)
%
%    also returns the posterior covariance matrix K at the locations XP (this is
%    an NP x NP covariance matrix). From a frequentist point of view, K can be
%    seen as the covariance matrix of the prediction errors.
%
% SPECIAL CASE
%
%    If ZI is empty, everything but ZP.mean is computed. Indeed, neither the
%    kriging variance ZP.var nor the matrices LAMBDA and MU actually depend on
%    the observed values.

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

function varargout = stk_predict (M_prior, x_obs, z_obs, x_prd)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);

varargout = cell (1, max (1, nargout));
[varargout{:}] = stk_predict (M_post, x_prd);

end % function


%!shared n, m, model, x0, x_obs, z_obs, x_prd, y_prd1, idx_obs, idx_prd
%!
%! n = 10;     % number of observations
%! m = n + 1;  % number of predictions
%! d = 1;      % dimension of the input space
%!
%! x0 = stk_sampling_regulargrid(n+m, d, [0; pi]);
%!
%! idx_obs = (2:2:(n+m-1))';
%! idx_prd = (1:2:(n+m))';
%!
%! x_obs = x0(idx_obs);
%! z_obs = sin (double (x_obs));
%! x_prd = x0(idx_prd);
%!
%! model = stk_model('stk_materncov32_iso');
%! model.param = log ([1.0; 2.1]);

%!error y_prd1 = stk_predict();
%!error y_prd1 = stk_predict(model);
%!error y_prd1 = stk_predict(model, x_obs);
%!error y_prd1 = stk_predict(model, x_obs, z_obs);
%!test  y_prd1 = stk_predict(model, x_obs, z_obs, x_prd);
%!error y_prd1 = stk_predict(model, x_obs, z_obs, x_prd, 0);

%!test  % nargout = 2
%! [y_prd1, lambda] = stk_predict (model, x_obs, z_obs, x_prd);
%! assert (isequal (size (lambda), [n m]));

%!test  % nargout = 2, compute only variances
%! [y_prd1, lambda] = stk_predict (model, x_obs, [], x_prd);
%! assert (isequal (size (lambda), [n m]));
%! assert (all (isnan (y_prd1.mean)));

%!test  % nargout = 3
%! [y_prd1, lambda, mu] = stk_predict (model, x_obs, z_obs, x_prd);
%! assert (isequal (size (lambda), [n m]));
%! assert (isequal (size (mu), [1 m]));  % ordinary kriging

%!test  % nargout = 4
%! [y_prd1, lambda, mu, K] = stk_predict (model, x_obs, z_obs, x_prd);
%! assert (isequal (size (lambda), [n m]));
%! assert (isequal (size (mu), [1 m]));  % ordinary kriging
%! assert (isequal (size (K), [m m]));

%!test  % predict on large set of locations
%! x_prd = stk_sampling_regulargrid (1e5, 1, [0; pi]);
%! y_prd = stk_predict (model, x_obs, z_obs, x_prd);

%!test  % predict on an observation point
%! % https://sourceforge.net/p/kriging/tickets/49/
%! [zp, lambda] = stk_predict (model, x_obs, z_obs, x_obs(4));
%! assert (isequal (z_obs(4), zp.mean))
%! assert (isequal (zp.var, 0))
%! lambda_ref = zeros (n, 1);  lambda_ref(4) = 1;
%! assert (isequal (lambda, lambda_ref))
