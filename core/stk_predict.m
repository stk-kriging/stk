% STK_PREDICT performs a kriging prediction from data
%
% CALL: ZP = stk_predict(MODEL, XI, ZI, XP)
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
% CALL: [ZP, LAMBDA, MU] = stk_predict(MODEL, XI, ZI, XP)
%
%    also returns the matrix of kriging weights LAMBDA and the matrix of
%    Lagrange multipliers MU.
%
% CALL: [ZP, LAMBDA, MU, K] = stk_predict(MODEL, XI, ZI, XP)
%
%    also returns the posterior covariance matrix K at the locations XP (this is
%    an NP x NP covariance matrix). From a frequentist point of view, K can be
%    seen as the covariance matrix of the prediction errors.
%
% SPECIAL CASE #1
%
%    If MODEL has a field 'Kx_cache', XI and XP are expected to be vectors of
%    integer indices. This feature is not fully documented as of today... If
%    XT is empty, it is assumed that predictions must be computed at all points
%    of the underlying discrete space.
%
% SPECIAL CASE #2
%
%    If ZI is empty, everything but ZP.mean is computed. Indeed, neither the
%    kriging variance ZP.var nor the matrices LAMBDA and MU actually depend on
%    the observed values.
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

function [zp, lambda, mu, K] = stk_predict(model, xi, zi, xt)

stk_narginchk(4, 4);

%=== todo: these should become options

display_waitbar = false;
block_size = [];
options = {display_waitbar, block_size};

%=== prepare lefthand side of the kriging equation

kreq = stk_kriging_equation(model, xi);

%=== solve the kriging system and extract all requested outputs

if nargout == 1,
    
    % note: calling @stk_kriging_equation.stk_predict without its second output
    % argument is more memory-efficient (we don't build full lambda_mu and RS
    % matrices)
    
    zp = stk_predict(kreq, zi, xt, options{:});
    
else
    
    [zp, kreq] = stk_predict(kreq, zi, xt, options{:});
    
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


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

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
%! z_obs = stk_feval(@sin, x_obs);
%! x_prd = x0(idx_prd);
%!
%! model = stk_model('stk_materncov32_iso');
%! model.order = 0; % this is currently the default, but better safe than sorry

%!error y_prd1 = stk_predict();
%!error y_prd1 = stk_predict(model);
%!error y_prd1 = stk_predict(model, x_obs);
%!error y_prd1 = stk_predict(model, x_obs, z_obs);
%!test  y_prd1 = stk_predict(model, x_obs, z_obs, x_prd);
%!error y_prd1 = stk_predict(model, x_obs, z_obs, x_prd, 0);

%!test
%! [y_prd1, lambda, mu, K] = stk_predict(model, x_obs, z_obs, x_prd);
%! assert(isequal(size(lambda), [n m]));
%! assert(isequal(size(mu), [1 m]));  % ordinary kriging
%! assert(isequal(size(K), [m m]));

%!test % use old-style .a structures (legacy)
%! y_prd2 = stk_predict(model, struct('a', double(x_obs)), ...
%!                      struct('a', double(z_obs)), struct('a', double(x_prd)));
%! assert(stk_isequal_tolrel(double(y_prd1), double(y_prd2)));

%%% test Kx_cache

%!test
%! model = stk_model('stk_materncov32_iso');
%! [model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);
%! y_prd3 = stk_predict(model, idx_obs, z_obs, idx_prd);
%! assert(stk_isequal_tolrel(double(y_prd1), double(y_prd3)));

%!test % same test,with idx_prd as a row vector
%! model = stk_model('stk_materncov32_iso');
%! [model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);
%! y_prd3 = stk_predict(model, idx_obs, z_obs, idx_prd');
%! assert(stk_isequal_tolrel(double(y_prd1), double(y_prd3)));

%!test
%! idx_all = (1:(n+m))';
%! model = stk_model('stk_materncov32_iso');
%! y_prd4 = stk_predict(model, idx_obs, z_obs, idx_all);
%! [model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);
%! y_prd5 = stk_predict(model, idx_obs, z_obs, []);
%! assert(stk_isequal_tolrel(double(y_prd4), double(y_prd5)));

