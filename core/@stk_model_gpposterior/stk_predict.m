% STK_PREDICT [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
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

function [zp, lambda, mu, K] = stk_predict (M_post, xt)

if nargin > 2
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% TODO: these should become options
block_size = [];

M_prior = M_post.prior_model;

%--- Convert and check input arguments: xt -------------------------------------

xt = double (xt);
% FIXME: check variable names

if (strcmp (M_prior.covariance_type, 'stk_discretecov')) && (isempty (xt))
    % In this case, predict on all points of the underlying discrete space
    nt = size (M_prior.param.K, 1);
    xt = (1:nt)';
else
    nt = size (xt, 1);
    if length (size (xt)) > 2
        stk_error (['The input argument xt should not have more than two ' ...
            'dimensions'], 'IncorrectSize');
    elseif ~ isequal (size (xt), [nt M_prior.dim])
        stk_error (sprintf (['The number of columns of xt (which is %d) ' ...
            'does not agree with the dimension of the model (which is ' ...
            '%d).'], size (xt, 2), M_prior.dim), 'IncorrectSize');
    end
end

%--- Prepare the output arguments ----------------------------------------------

zp_v = zeros (nt, 1);
compute_prediction = ~ isempty (M_post.output_data);

% compute the kriging prediction, or just the variances ?
if compute_prediction
    zp_a = zeros (nt, 1);
else
    zp_a = nan (nt, 1);
end

%--- Choose nb_blocks & block_size ---------------------------------------------

n_obs = size (M_post.input_data, 1);

if isempty (block_size)
    MAX_RS_SIZE = 5e6;  SIZE_OF_DOUBLE = 8;  % in bytes
    block_size = ceil (MAX_RS_SIZE / (n_obs * SIZE_OF_DOUBLE));
end

if nt == 0
    % skip main loop
    nb_blocks = 0;
else
    % blocks of size approx. block_size
    nb_blocks = max (1, ceil (nt / block_size));
    block_size = ceil (nt / nb_blocks);
end

% The full lambda_mu matrix is only needed when nargout > 1
if nargout > 1
    lambda_mu = zeros (n_obs + get (M_post.kreq, 'r'), nt);
end

% The full RS matrix is only needed when nargout > 3
if nargout > 3
    RS = zeros (size (lambda_mu));
end

%--- MAIN LOOP (over blocks) ---------------------------------------------------

% TODO: this loop should be parallelized !!!

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size * (block_num - 1);
    idx_end = min (nt, idx_beg + block_size - 1);
    idx = idx_beg:idx_end;
    
    % solve the kriging equation for the current block
    xt_ = xt(idx, :);
    kreq = stk_make_kreq (M_post, xt_);
    
    % compute the kriging mean
    if compute_prediction
        zp_a(idx) = (get (kreq, 'lambda'))' * (double (M_post.output_data));
    end
    
    % The full lambda_mu matrix is only needed when nargout > 1
    if nargout > 1
        lambda_mu(:, idx) = get (kreq, 'lambda_mu');
    end
    
    % The full RS matrix is only needed when nargout > 3
    if nargout > 3
        RS(:, idx) = get (kreq, 'RS');
    end
    
    % compute kriging variances (this does NOT include the noise variance)
    zp_v(idx) = stk_make_matcov (M_prior, xt_, xt_, true) ...
        - get (kreq, 'delta_var');
    
    % note: the following modification computes prediction variances for noisy
    % variance, i.e., including the noise variance also
    %    zp_v(idx) = stk_make_matcov (M_prior, xt_, [], true) ...
    %                 - get (kreq, 'delta_var');
    
    b = (zp_v < 0);
    if any (b)
        zp_v(b) = 0.0;
        warning('STK:stk_predict:NegativeVariancesSetToZero', sprintf ( ...
            ['Correcting numerical inaccuracies in kriging variance.\n' ...
            '(%d negative variances have been set to zero)'], sum (b)));
    end
    
end

%--- Ensure exact prediction at observation points for noiseless models --------

if ~ stk_isnoisy (M_prior)
    
    % FIXME: Fix the kreq object instead ?
    
    xi = double (M_post.input_data);
    zi = double (M_post.output_data);
    
    [b, loc] = ismember (xt, xi, 'rows');
    if sum (b) > 0
        
        if compute_prediction
            zp_a(b) = zi(loc(b));
        end
        
        zp_v(b) = 0.0;
        
        if nargout > 1
            lambda_mu(:, b) = 0.0;
            lambda_mu(sub2ind (size (lambda_mu), loc(b), find (b))) = 1.0;
        end
    end
end


%--- Prepare outputs -----------------------------------------------------------

zp = stk_dataframe ([zp_a zp_v], {'mean' 'var'});

if nargout > 1 % lambda requested
    lambda = lambda_mu(1:n_obs, :);
end

if nargout > 2 % mu requested
    mu = lambda_mu((n_obs+1):end, :);
end

if nargout > 3
    K0 = stk_make_matcov (M_prior, xt, xt);
    deltaK = lambda_mu' * RS;
    K = K0 - 0.5 * (deltaK + deltaK');
end

end % function

%#ok<*SPWRN>


%!shared n, m, M_post, M_prior, x0, x_obs, z_obs, x_prd, y_prd, idx_obs, idx_prd
%!
%! n = 10;     % number of observations
%! m = n + 1;  % number of predictions
%! d = 1;      % dimension of the input space
%!
%! x0 = (linspace (0, pi, n + m))';
%!
%! idx_obs = (2:2:(n+m-1))';
%! idx_prd = (1:2:(n+m))';
%!
%! x_obs = x0(idx_obs);
%! z_obs = sin (x_obs);
%! x_prd = x0(idx_prd);
%!
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);
%!
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);

%!error y_prd = stk_predict (M_post);
%!test  y_prd = stk_predict (M_post, x_prd);
%!error y_prd = stk_predict (M_post, [x_prd x_prd]);
%!error y_prd = stk_predict (M_post, x_prd, 0);

%!test  % nargout = 2
%! [y_prd1, lambda] = stk_predict (M_post, x_prd);
%! assert (stk_isequal_tolrel (y_prd, y_prd1));
%! assert (isequal (size (lambda), [n m]));

%!test  % nargout = 3
%! [y_prd1, lambda, mu] = stk_predict (M_post, x_prd);
%! assert (stk_isequal_tolrel (y_prd, y_prd1));
%! assert (isequal (size (lambda), [n m]));
%! assert (isequal (size (mu), [1 m]));  % ordinary kriging

%!test  % nargout = 4
%! [y_prd1, lambda, mu, K] = stk_predict (M_post, x_prd);
%! assert (stk_isequal_tolrel (y_prd, y_prd1));
%! assert (isequal (size (lambda), [n m]));
%! assert (isequal (size (mu), [1 m]));  % ordinary kriging
%! assert (isequal (size (K), [m m]));

%!test  % nargout = 2, compute only variances
%! M_post1 = stk_model_gpposterior (M_prior, x_obs, []);
%! [y_prd_nan, lambda] = stk_predict (M_post1, x_prd);
%! assert (isequal (size (lambda), [n m]));
%! assert (all (isnan (y_prd_nan.mean)));

%!test % discrete model (prediction indices provided)
%! M_prior1 = stk_model ('stk_discretecov', M_prior, x0);
%! M_post1 = stk_model_gpposterior (M_prior1, idx_obs, z_obs);
%! y_prd1 = stk_predict (M_post1, idx_prd);
%! assert (stk_isequal_tolrel (y_prd, y_prd1));

%!test % discrete model (prediction indices *not* provided)
%! M_prior1 = stk_model ('stk_discretecov', M_prior, x0);
%! M_post1 = stk_model_gpposterior (M_prior1, idx_obs, z_obs);
%! y_prd1 = stk_predict (M_post1, []);  % predict them all!
%! assert (stk_isequal_tolrel (y_prd, y_prd1(idx_prd, :)));
