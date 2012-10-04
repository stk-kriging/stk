% STK_PREDICT performs a kriging prediction from data 
%
% CALL: ZP = stk_predict(MODEL, XP)
%
%    computes the kriging predictor ZP at the points XP, given MODEL. 
%    In general (see special cases below), XP and ZP are structures 
%    whose field 'a' contains the actual numerical data.
%    More precisely, on a DIM-dimensional factor space,
%
%     * XP.a must be a NP x DIM matrix, where NP is the number of prediction
%       points,
%     * ZP.a is a column vector of length NP.
%
%    Additionally to the predicted values ZP.a, stk_predict() returns the
%    kriging variances ZP.v at the same points. ZP.v is a column vector of
%    length NP.
%
% CALL: [ZP, LAMBDA, MU] = stk_predict(MODEL, XP)
%
%    also returns the matrix of kriging weights LAMBDA and the matrix of
%    Lagrange multipliers MU.
%
% SPECIAL CASE #1
%
%    If MODEL.domain.type is discrete, MODEL.observations.x.a and XP.a are expected
%    to be vectors of integer indices. This feature is not fully documented
%    as of today... If XP is empty, it is assumed that predictions must be 
%    computed at all points of the underlying discrete space.
%
% SPECIAL CASE #2
%
%    If MODEL.observations.z is empty, everything but ZP.a is computed. 
%    Indeed, neither the kriging variance ZP.v nor the matrices LAMBDA and
%    MU actually depend on the observed values.
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

function [zp, lambda, mu] = stk_predict(model, xp)

stk_narginchk(2, 2);

ni = model.observations.n;

%=== process argument xp according to the nature of the domain
switch model.domain.type
  case 'discrete',
    if isempty(xp), xp.a = 1:model.domain.nt; end
  case 'continuous',
    assert( ~isempty(xp.a) );
  otherwise
    error('model.domain.type should be either "continuous" or "discrete"');
end
np = size(xp.a, 1);

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
    nb_blocks = ceil( np / block_size );
end

block_size = ceil( np / nb_blocks );

%=== prepare lefthand side of the kriging equation

[Kii,Pi] = stk_make_matcov( model,  model.observations.x );

LS = [ [ Kii, Pi                ]; ...
       [ Pi', zeros(size(Pi,2)) ] ];

[LS_Q,LS_R] = qr( LS ); % orthogonal-triangular decomposition

%=== prepare the output arguments

zp = struct('v', zeros(np,1));
compute_prediction = ~isempty(model.observations.z);

% compute the kriging prediction, or just the variances ?
if compute_prediction, zp.a = zeros(np,1); 
else zp.a = zeros(np,0); end

return_weights = ( nargout > 1 ); % return kriging weights ?
if return_weights, lambda = zeros(ni,np); end

return_lm = ( nargout > 2 ); % return Lagrange multipliers ?
if return_lm, mu = zeros(size(Pi,2),np); end
    
%=== MAIN LOOP (over blocks)

linsolve_opt = struct( 'UT', true );

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size*(block_num-1);
    idx_end = min( np, idx_beg+block_size-1 );
    idx = idx_beg:idx_end;
    
    % extract the block of prediction locations
    switch model.domain.type
      case 'discrete'
        xt_block = xp(idx);
      case 'continuous'
        xt_block = struct('a', xp.a(idx,:));
    end
    
    % right-hand side of the kriging equation
    [Kti,Pt] = stk_make_matcov( model, xt_block, model.observations.x );
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
        zp.a(idx) = lambda_mu(1:ni,:)' * model.observations.z.a; end
    
    % compute kriging variances (STATIONARITY ASSUMED)
    zp.v(idx) = LS(1,1) - dot(lambda_mu, RS)';
    
    if display_waitbar,
        waitbar( idx_end/np, hwb, sprintf( ...
            'In stk\\_predict(): %d/%d predictions completed',idx_end,np) );
    end
end

if display_waitbar, close(hwb); end

end

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared model, x0, x_obs, z_obs, x_prd, y_prd1, idx_obs, idx_prd
%!
%! n = 20; % 10 observations + 10 predictions
%! d = 1;  % dimension of the input space
%!
%! x0 = stk_sampling_regulargrid(n, d, [0; pi]);
%!
%! idx_obs = 1:2:n;
%! idx_prd = 2:2:n;
%!
%! x_obs = struct('a', x0.a(idx_obs));
%! z_obs = stk_feval(@sin, x_obs);
%! x_prd = struct('a', x0.a(idx_prd));
%! 
%! model = stk_model('stk_materncov32_iso');

%!error y_prd1 = stk_predict();
%!error y_prd1 = stk_predict(model);
%!error y_prd1 = stk_predict(model, x_obs);
%!error y_prd1 = stk_predict(model, x_obs, z_obs);
%!test  y_prd1 = stk_predict(model, x_obs, z_obs, x_prd);
%!error y_prd1 = stk_predict(model, x_obs, z_obs, x_prd, 0);
%!error y_prd1 = stk_predict(model, x_obs, z_obs, x_prd, 0, 1);

%!test
%!
%! %% use of Kx_cache
%! model = stk_model('stk_materncov32_iso');
%! [model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);
%! y_prd2 = stk_predict(model, idx_obs, z_obs, idx_prd);
%! 
%! %% check that both methods give the same result
%! assert(stk_isequal_tolrel(y_prd1, y_prd2));
