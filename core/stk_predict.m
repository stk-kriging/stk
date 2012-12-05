% STK_PREDICT performs a kriging prediction from data 
%
% CALL: ZP = stk_predict(MODEL, XI, ZI, XP)
%
%    computes the kriging predictor ZP at the points XP, given the observations
%    (XI, ZI) and the prior MODEL. In general (see special cases below), XI, ZI,
%    XP and ZP are structures whose field 'a' contains the actual numerical
%    data. More precisely, on a DIM-dimensional factor space,
%
%     * XI.a must be a NI x DIM matrix, where NI is the number of observations,
%     * ZI.a must be a column vector of length NI,
%     * XP.a must be a NP x DIM matrix, where NP is the number of prediction
%       points,
%     * ZP.a is a column vector of length NP.
%
%    Additionally to the predicted values ZP.a, stk_predict() returns the
%    kriging variances ZP.v at the same points. ZP.v is a column vector of
%    length NP.
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
%    integer indices (instead of structures with an 'a' field). This feature is
%    not fully documented as of today... If XT is empty, it is assumed that
%    predictions must be computed at all points of the underlying discrete
%    space.
%
% SPECIAL CASE #2
%
%    If ZI is empty, everything but ZP.a is computed. Indeed, neither the
%    kriging variance ZP.v nor the matrices LAMBDA and MU actually depend on the
%    observed values.
% 
% EXAMPLE: see examples/example01.m

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

xi = stk_datastruct(xi);
zi = stk_datastruct(zi);
xt = stk_datastruct(xt);

%=== use indices or matrices for xi & xt ?

use_indices = isfield(model,'Kx_cache');

if use_indices
    if isempty(xt.a)
        xt.a = 1:size(model.Kx_cache, 1);
    end
    xi.a = ensure_column_vector_(xi.a, 'xi.a');
    xt.a = ensure_column_vector_(xt.a, 'xt.a');
end

ni = size(xi.a, 1); % number of observations
nt = size(xt.a, 1); % number of test points
assert(nt > 0);

if use_indices
    xi = xi.a(:);
    xt = xt.a(:);
end

assert(isempty(zi.a) || (size(zi.a,1) == ni));

%=== handle other optional arguments

% parser = inputParser; % parse optional arguments
% parser.addOptional( 'BlockSize', [] );
% parser.addOptional( 'DisplayWaitBar', false );
% parser.parse( varargin{:} );
% 
% display_waitbar = parser.Results.DisplayWaitBar;
% if display_waitbar,
%     hwb = waitbar(0,'In stk\_predict(). Please wait...');
%     set( hwb, 'Name', 'stk_predict' );
% end
% 
% block_size = parser.Results.BlockSize;

display_waitbar = false;
block_size = [];

%=== prepare lefthand side of the kriging equation

[Kii,Pi] = stk_make_matcov(model,  xi);

LS = [[ Kii, Pi                ]; ...
      [ Pi', zeros(size(Pi,2)) ]];

[LS_Q, LS_R] = qr(LS); % orthogonal-triangular decomposition

%=== prepare the output arguments

zp = struct('v',zeros(nt,1));
compute_prediction = ~isempty(zi.a);

% compute the kriging prediction, or just the variances ?
if compute_prediction, zp.a = zeros(nt, 1); 
else zp.a = zeros(nt, 0); end

return_weights = (nargout > 1); % return kriging weights ?
if return_weights, lambda = zeros(ni, nt); end

return_lm = (nargout > 2); % return Lagrange multipliers ?
if return_lm, mu = zeros(size(Pi, 2), nt); end

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

linsolve_opt = struct('UT', true);

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size * (block_num - 1);
    idx_end = min(nt, idx_beg + block_size - 1);
    idx = idx_beg:idx_end;
    
    % extract the block of prediction locations
    if use_indices, xt_block = xt(idx);
    else xt_block = struct('a', xt.a(idx,:)); end
    
    % right-hand side of the kriging equation
    [Kti, Pt] = stk_make_matcov(model, xt_block, xi);
    RS = [Kti Pt]';
        
    % solve the upper-triangular system to get the extended
    % kriging weights vector (weights + Lagrange multipliers)
    if stk_is_octave_in_use(),
        lambda_mu = LS_R \ (LS_Q' * RS); % linsolve is missing in Octave
    else        
        lambda_mu = linsolve(LS_R, LS_Q' * RS, linsolve_opt);
    end
    
    if return_weights, % extract weights
        lambda(:, idx) = lambda_mu(1:ni, :); end
    
    if return_lm, % extracts Lagrange multipliers
        mu(:, idx) = lambda_mu((ni+1):end, :); end
    
    if compute_prediction, % compute the kriging mean
        zp.a(idx) = lambda_mu(1:ni, :)' * zi.a; end
    
    % compute kriging variances (this does NOT include the noise variance)
    zp.v(idx) = stk_make_matcov(model, xt, xt, true) - dot(lambda_mu, RS)';

    % note: the following modification computes prediction variances for noisy
    % variance, i.e., including the noise variance also
    % zp.v(idx) = stk_make_matcov(model, xt, [], true) - dot(lambda_mu, RS)';
    
    b = (zp.v < 0);
    if any(b),        
        zp.v(b) = 0.0;
        warning(sprintf(['Correcting numerical inaccuracies in kriging variance.\n' ...
            '(%d negative variances have been set to zero)'], sum(b)));
    end
    
    if display_waitbar,
        waitbar( idx_end/nt, hwb, sprintf( ...
            'In stk\\_predict(): %d/%d predictions completed',idx_end,nt) );
    end
end

% compute posterior covariance matrix (if requested)
if return_K,
    assert(nb_blocks == 1); % sanity check
    K0 = stk_make_matcov(model, xt);
    K = K0 - [lambda; mu]' * RS;
    K = 0.5 * (K + K'); % enforce symmetry
end
        
if display_waitbar, close(hwb); end

end


function v = ensure_column_vector_(u, uname)
if size(u, 2) ~= 1,
    if size(u, 1) == 1,
        v = u';
    else
        errmsg = sprintf('%s should be a vector of indices', uname);
        stk_error(errmsg, 'IncorrectArgument');
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
%! idx_obs = 2:2:(n+m-1);
%! idx_prd = 1:2:(n+m);
%!
%! x_obs = struct('a', x0.a(idx_obs));
%! z_obs = stk_feval(@sin, x_obs);
%! x_prd = struct('a', x0.a(idx_prd));
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
%!
%! [y_prd1, lambda, mu, K] = stk_predict(model, x_obs, z_obs, x_prd); 
%! assert(isequal(size(lambda), [n m]));
%! assert(isequal(size(mu), [1 m]));  % ordinary kriging
%! assert(isequal(size(K), [m m]));

%!test
%!
%! %% use of Kx_cache
%! model = stk_model('stk_materncov32_iso');
%! [model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);
%! y_prd2 = stk_predict(model, idx_obs, z_obs, idx_prd);
%! 
%! %% check that both methods give the same result
%! assert(stk_isequal_tolrel(y_prd1, y_prd2));
