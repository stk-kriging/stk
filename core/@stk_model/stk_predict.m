% STK_PREDICT performs a kriging prediction from data
%
% CALL: ZP = stk_predict(MODEL, XP)
%
%    performs a kriging prediction at the points XP, using the kriging model
%    MODEL. The input argument XP can be either a numerical array or a
%    dataframe. On a factor space of dimension DIM, XP must have size NP x DIM,
%    where NP is the number of prediction points. The output ZP is a dataframe
%    of size NP x 2, with:
%
%     * the kriging predictor in the first column (ZP.mean), and
%     * the kriging variance in the second column (ZP.var).
%
% CALL: [ZP, LAMBDA, MU] = stk_predict(MODEL, XP)
%
%    also returns the matrix of kriging weights LAMBDA and the matrix of
%    Lagrange multipliers MU.
%
% CALL: [ZP, LAMBDA, MU, K] = stk_predict(MODEL, XP)
%
%    also returns the posterior covariance matrix K at the locations XP (this is
%    an NP x NP covariance matrix). From a frequentist point of view, K can be
%    seen as the covariance matrix of the prediction errors.
%
% SPECIAL CASE #1
%
%    If MODEL.domain.type is discrete, MODEL.observations.x and XP are expected
%    to be vectors of integer indices. This feature is not fully documented
%    as of today... If XP is empty, it is assumed that predictions must be
%    computed at all points of the underlying discrete space.
%
% SPECIAL CASE #2
%
%    If MODEL.observations.z is empty, everything but ZP.mean is computed.
%    Indeed, neither the kriging variance ZP.var nor the matrices LAMBDA and
%    MU actually depend on the observed values.
%
% EXAMPLE: see examples/example01.m

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function [zp, lambda, mu, K] = stk_predict(model, xt)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

%=== todo: these should become options

display_waitbar = false;
block_size = [];
options = {display_waitbar, block_size};

%=== prepare lefthand side of the kriging equation

kreq = stk_kriging_equation(model);

%=== solve the kriging system and extract all requested outputs

if nargout == 1,
    
    % note: calling @stk_kriging_equation.stk_predict without its second output
    % argument is more memory-efficient (we don't build full lambda_mu and RS
    % matrices)
    
    zp = stk_predict(kreq, model.observations.z, xt, options{:});
    
else
    
    [zp, kreq] = stk_predict(kreq, model.observations.z, xt, options{:});
    
    % extracts kriging weights (if requested)
    if nargout > 1,
        lambda = kreq.lambda;
    end
    
    % extracts Lagrange multipliers (if requested)
    if nargout > 2,
        mu = kreq.mu;
    end
    
    % compute posterior covariance matrix (if requested)
    if nargout > 3,
        nt = size(xt, 1);
        K = stk_posterior_matcov(kreq, 1:nt, 1:nt, false);
    end
    
end

end


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
%! model = stk_setobs(model, x_obs, z_obs);
%! model.randomprocess.priormean = stk_lm('constant');
%! % this is currently the default, but better safe than sorry

%!error y_prd1 = stk_predict();
%!error y_prd1 = stk_predict(model);
%!test  y_prd1 = stk_predict(model, x_prd);
%!error y_prd1 = stk_predict(model, x_prd, 0);

%!test
%! [y_prd1, lambda, mu, K] = stk_predict(model, x_prd);
%! assert(isequal(size(lambda), [n m]));
%! assert(isequal(size(mu), [1 m]));  % ordinary kriging
%! assert(isequal(size(K), [m m]));
