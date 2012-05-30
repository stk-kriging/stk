% STK_PREDICT performs a kriging prediction from data 
%
% CALL: [zp, lambda, mu] = stk_predict(model, xi, zi, xt,...)
%
% STK_PREDICT computes a kriging approximation given data and a model
%
% FIXME: documentation incomplete
%
% USE #1: if model.Kx_cache exist,
%   - it is assumed that xi and xt are indices (integers)
%   - xi is required
%   - xt is optional (can be empty)
%
% USE #2: otherwise,
%   - xi and xt are expected to be structures, whose field 'a' contains
%     the observed points (matrix of size n x d, where n is the number 
%     of points and d is the dimension of the factor space)
%   - both arguments are required
% 
% EXAMPLE: see examples/example01.m

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function [zp, lambda, mu] = stk_predict(model, xi, zi, xt, varargin)

%=== use indices or matrices for xi & xt ?

use_indices = isfield(model,'Kx_cache');

if use_indices,
    xi = xi(:);
    ni = size(xi, 1); % number of observations
    if isempty(xt), xt = 1:size(model.Kx_cache,1); end
    nt = length(xt);
else
    ni = size(xi.a, 1); % number of observations
    assert( ~isempty(xt.a) );
    nt = size(xt.a,1);
end

assert( isempty(zi) || (size(zi.a,1)==ni) );
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

[Kii,Pi] = stk_make_matcov( model,  xi );

LS = [ [ Kii, Pi                ]; ...
       [ Pi', zeros(size(Pi,2)) ] ];

[LS_Q,LS_R] = qr( LS ); % orthogonal-triangular decomposition

%=== prepare the output arguments

zp = struct('v',zeros(nt,1));
compute_prediction = ~isempty(zi);

% compute the kriging prediction, or just the variances ?
if compute_prediction, zp.a = zeros(nt,1); 
else zp.a = zeros(nt,0); end

return_weights = ( nargout > 1 ); % return kriging weights ?
if return_weights, lambda = zeros(ni,nt); end

return_lm = ( nargout > 2 ); % return Lagrange multipliers ?
if return_lm, mu = zeros(size(Pi,2),nt); end
    
%=== choose nb_blocks & block_size

if isempty( block_size )
    MAX_RS_SIZE = 5e6; SIZE_OF_DOUBLE = 8; % in bytes
    block_size = ceil( MAX_RS_SIZE/(ni*SIZE_OF_DOUBLE) );
end

if block_size == inf, 
    % biggest possible block size    
    nb_blocks = 1;
else
    % blocks of size approx. block_size
    nb_blocks = ceil( nt / block_size );
end

block_size = ceil( nt / nb_blocks );


%=== MAIN LOOP (over blocks)

linsolve_opt = struct( 'UT', true );

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size*(block_num-1);
    idx_end = min( nt, idx_beg+block_size-1 );
    idx = idx_beg:idx_end;
    
    % extract the block of prediction locations
    if use_indices, xt_block = xt(idx);
    else xt_block = struct('a',xt.a(idx,:)); end
    
    % right-hand side of the kriging equation
    [Kti,Pt] = stk_make_matcov( model, xt_block, xi );
    RS = [ Kti Pt ]';
    
    % solve the upper-triangular system to get the extended
    % kriging weights vector (weights + Lagrange multipliers)
    if stk_is_octave_in_use(),
        lambda_mu = LS_R \ ( LS_Q'*RS ); % linsolve is missing in Octave
    else        
        lambda_mu = linsolve( LS_R, LS_Q'*RS, linsolve_opt );
    end
    
    if return_weights, % extract weights
        lambda(:,idx) = lambda_mu(1:ni,:); end
    
    if return_lm, % extracts Lagrange multipliers
        mu(:,idx) = lambda_mu((ni+1):end,:); end
    
    if compute_prediction, % compute the kriging mean
        zp.a(idx) = lambda_mu(1:ni,:)' * zi.a; end
    
    % compute kriging variances (STATIONARITY ASSUMED)
    zp.v(idx) = LS(1,1) - dot(lambda_mu, RS)';
    
    if display_waitbar,
        waitbar( idx_end/nt, hwb, sprintf( ...
            'In stk\\_predict(): %d/%d predictions completed',idx_end,nt) );
    end
end

if display_waitbar, close(hwb); end

end


