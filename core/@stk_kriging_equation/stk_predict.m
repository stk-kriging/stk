% STK_PREDICT_  [STK internal function]

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

function [zp, kreq] = stk_predict ...
    (kreq, zi, xt, display_waitbar, block_size)

%=== convert zi and check its size

zi = double(zi);

ni = size(kreq.xi, 1);  % number of observations

if ~(isempty(zi) || isequal(size(zi), [ni 1]))
    stk_error('zi must have size ni x 1.', 'IncorrectSize');
end

%=== convert xt and get its size

xt = double(xt);

if isfield(kreq.model, 'Kx_cache') % use indices
    
    if isempty(xt)
        xt = (1:size(kreq.model.Kx_cache, 1))';
    elseif ~iscolumn(xt)
        warning('STK:stk_predict:IncorrectSize', 'xt should be a column.');
        xt = xt(:);
    end
    
end

nt = size(xt, 1);

%=== optional arguments

if nargin < 4,
    display_waitbar = false;
end

if nargin < 5,
    block_size = [];
end

%=== prepare the output arguments

zp_v = zeros(nt, 1);
compute_prediction = ~isempty(zi);

% compute the kriging prediction, or just the variances ?
if compute_prediction,
    zp_a = zeros(nt, 1);
else
    zp_a = nan(nt, 1);
end
    
%=== choose nb_blocks & block_size

% note: only one block if return_K == true
%       (we need the full set of lambda's and mu's to compute K)

if isempty(block_size)
    MAX_RS_SIZE = 5e6; SIZE_OF_DOUBLE = 8; % in bytes
    block_size = ceil(MAX_RS_SIZE / (ni * SIZE_OF_DOUBLE));
end

% blocks of size approx. block_size
nb_blocks = max(1, ceil(nt / block_size));

block_size = ceil(nt / nb_blocks);

% if we want to return a full kreq object in the case where several blocks are
% used, we need to recompose full lambda_mu and RS matrices.
if (nargin > 1) && (nb_blocks > 1)
    lambda_mu = zeros(size(kreq.LS_Q, 1), nt);
    RS = zeros(size(lambda_mu));
end

%=== MAIN LOOP (over blocks)

% TODO: this loop should be parallelized !!!

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size * (block_num - 1);
    idx_end = min(nt, idx_beg + block_size - 1);
    idx = idx_beg:idx_end;
    
    % extract the block of prediction locations
    xt_block = xt(idx, :);
    
    % solve the kriging equation using xt_block for the right-hand side
    kreq = linsolve(kreq, xt_block);

    % compute the kriging mean
    if compute_prediction,
        zp_a(idx) = (kreq.lambda_mu(1:ni, :))' * zi;
    end

    if (nargin > 1) && (nb_blocks > 1)
        lambda_mu(:, idx) = kreq.lambda_mu;
        RS(:, idx) = kreq.RS;
    end
    
    % compute kriging variances (this does NOT include the noise variance)
    zp_v(idx) = stk_posterior_matcov(kreq, 1:length(idx), 1:length(idx), true);
    
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

if display_waitbar,
    close(hwb);
end

%=== Prepare outputs

zp = stk_dataframe([zp_a zp_v], {'mean' 'var'});

if (nargin > 1) && (nb_blocks > 1)
    kreq.lambda_mu = lambda_mu;
    kreq.RS = RS;
end

end
