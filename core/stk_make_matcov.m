% STK_MAKE_MATCOV computes a covariance matrix
%
% CALL: [K, P] = stk_make_matcov(x, [], model)
%
% CALL: [K, P] = stk_make_matcov(x, xco, model)
%
% CALL: [K, P] = stk_make_matcov(x, model)
%
% BE CAREFUL: stk_make_matcov(x,model) and stk_makematcov(x,x,model) are
% NOT equivalent if model.lognoisevariance exists (in the first case the
% nois variance is added on the diagonal).

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

function [K, P] = stk_make_matcov(x, arg2, arg3)

if nargin < 2, error('Not enough input arguments'); end

%=== guess which syntax has been used based on the second input arg

switch nargin
    case 2, % stk_make_matcov(x, model)
        model = arg2;
        make_matcov_auto = true;
    case 3, % stk_make_matcov(x, xco, model)
        xco = arg2;
        model = arg3;        
        make_matcov_auto = isempty(xco);
    otherwise
        error('Incorrect number of input arguments.');
end

if isfield(model, 'Kx_cache'),
    
    % handle the case where a 'Kx_cache' field is present    
    if make_matcov_auto,
        K = model.Kx_cache(x, x);
    else
        K = model.Kx_cache(x, xco);
    end
    
else % handle the case where the covariance matrix must be computed
    
    %=== blocking parameters
    
    % If the size of the covariance matrix to be computed is smaller than
    % MIN_SIZE_FOR_BLOCKING, we don't even consider using parfor.
    MIN_SIZE_FOR_BLOCKING = 500^2;
    
    % If it is decided to use parfor, the number of blocks will be chosen in
    % such a way that blocks smaller than MIN_BLOCK_SIZE are never used
    MIN_BLOCK_SIZE = 100^2;
    
    %=== decide whether blocks should be used or not
    
    if isfield(model,'Kx_cache'), % SYNTAX: x(indices), model
        ncores = 1; % avoids a call to matlabpool() which is slow
    else
        N = size(x.a,1);
        if make_matcov_auto, N=N*N; else N=N*size(xco.a,1); end
        if (N < MIN_SIZE_FOR_BLOCKING) || ~stk_is_pct_installed(),
            ncores = 1; % do not use blocking
        else
            ncores = max( 1, matlabpool('size') );
            % note: matlabpool('size') returns 0 if the PCT is not started
        end
    end
    
    %=== call the subfunction that does the actual computations
    
    if make_matcov_auto,
        %
        % FIXME: avoid computing twice each off-diagonal term
        %
        if ncores == 1, % shortcut when blocking is not used
            K = feval( model.covariance_type, x, x, model.param );
        else
            K = stk_make_matcov_auto_parfor( x, model, ncores, MIN_BLOCK_SIZE );
        end
        if isfield( model, 'lognoisevariance' ),
            K = K + stk_noisecov( size(K,1), model.lognoisevariance );
        end
    else
        if ncores == 1, % shortcut when blocking is not used
            K = feval( model.covariance_type, x, xco, model.param );
        else
            K = stk_make_matcov_inter_parfor( x, xco, model, ncores, MIN_BLOCK_SIZE );
        end
    end
    
end

%=== compute the regression functions

if nargout > 1, P = stk_ortho_func( x, model ); end

end
