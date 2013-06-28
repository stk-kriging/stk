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

xi = double(xi);
zi = double(zi);
xt = double(xt);

%=== use indices or matrices for xi & xt ?

if isfield(model, 'Kx_cache') % use indices
    if isempty(xt)
        xt = (1:size(model.Kx_cache, 1))';
    end
    if ~(iscolumn(xi) && iscolumn(xt))
        errmsg = 'Both xi and xt must be columns.';
        stk_error(errmsg, 'IncorrectSize');
    end
end

ni = size(xi, 1); % number of observations
nt = size(xt, 1); % number of test points
assert(nt > 0);

assert(isempty(zi) || (size(zi, 1) == ni));

%=== handle other optional arguments

display_waitbar = false;
block_size = [];

%=== prepare lefthand side of the kriging equation

kreq = stk_kriging_equation(model, xi);

%=== prepare the output arguments

zp_v = zeros(nt, 1);
compute_prediction = ~isempty(zi);

% compute the kriging prediction, or just the variances ?
if compute_prediction,
    zp_a = zeros(nt, 1);
else
    zp_a = nan(nt, 1);
end

% return kriging weights ?
return_weights = (nargout > 1);
if return_weights,
    lambda = zeros(ni, nt);
end

% return Lagrange multipliers ?
return_lm = (nargout > 2);
if return_lm,
    mu = zeros(size(kreq.LS_Q, 1) - ni, nt);
end

return_K = (nargout > 3); % return posterior covariance matrix ?

%=== choose nb_blocks & block_size

% note: only one block if return_K == true
%       (we need the full set of lambda's and mu's to compute K)

if (~return_K) && isempty(block_size)
    MAX_RS_SIZE = 5e6; SIZE_OF_DOUBLE = 8; % in bytes
    block_size = ceil(MAX_RS_SIZE / (ni * SIZE_OF_DOUBLE));
end

if return_K || (block_size == inf),
    % biggest possible block size
    nb_blocks = 1;
else
    % blocks of size approx. block_size
    nb_blocks = ceil(nt / block_size);
end

block_size = ceil(nt / nb_blocks);

%=== MAIN LOOP (over blocks)

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size * (block_num - 1);
    idx_end = min(nt, idx_beg + block_size - 1);
    idx = idx_beg:idx_end;
    
    % extract the block of prediction locations
    xt_block = xt(idx, :);
    
    % solve the kriging equation using xt_block for the right-hand side
    kreq = linsolve(kreq, xt_block);
           
    % extract weights
    if return_weights || compute_prediction
        
        lambda = kreq.lambda;
        
        if return_weights
            lambda(:, idx) = lambda;
        end
        
        % compute the kriging mean
        if compute_prediction,
            zp_a(idx) = lambda' * zi;
        end

    end
    
    % extracts Lagrange multipliers
    if return_lm,
        mu(:, idx) = kreq.mu;
    end
        
    % compute kriging variances (this does NOT include the noise variance)
    zp_v(idx) = stk_posterior_matcov(kreq, 1:nt, 1:nt, true);
    
    % note: the following modification computes prediction variances for noisy
    % variance, i.e., including the noise variance also
    % zp_v(idx) = stk_posterior_matcov(kreq, 1:nt, [], true);
    
    b = (zp_v < 0);
    if any(b),
        zp_v(b) = 0.0;
        warning('STK:stk_predict:NegativeVariancesSetToZero', sprintf( ...
            ['Correcting numerical inaccuracies in kriging variance.\n' ...
            '(%d negative variances have been set to zero)'], sum(b)));
    end
    
    if display_waitbar,
        waitbar(idx_end/nt, hwb, sprintf( ...
            'In stk\\_predict(): %d/%d predictions completed',idx_end,nt));
    end
end

% compute posterior covariance matrix (if requested)
if return_K,
    assert(nb_blocks == 1); % sanity check    
    K = stk_posterior_matcov(kreq, 1:nt, 1:nt, false);
end

if display_waitbar,
    close(hwb);
end

zp = stk_dataframe([zp_a zp_v], {'mean' 'var'});

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

%!test % use of Kx_cache
%! model = stk_model('stk_materncov32_iso');
%! [model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);
%! y_prd3 = stk_predict(model, idx_obs, z_obs, idx_prd);
%! assert(stk_isequal_tolrel(double(y_prd1), double(y_prd3)));
