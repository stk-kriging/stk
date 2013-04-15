% STK_MAKE_MATCOV computes a covariance matrix (and a design matrix).
%
% CALL: [K, P] = stk_make_matcov(MODEL, X0)
%
%    computes the covariance matrix K and the design matrix P for the model
%    MODEL at the set of points X0. For a set of N points on a DIM-dimensional
%    space of factors, X0 is expected to be a structure whose field 'a' contains
%    an N x DIM matrix. As a result, a matrix K of size N x N and a matrix P of
%    size N x L are obtained, where L is the number of regression functions in
%    the linear part of the model; e.g., L = 1 if MODEL.order is zero (ordinary
%    kriging).
%
% CALL: K = stk_make_matcov(MODEL, X0, X1)
%
%    computes the covariance matrix K for the model MODEL between the sets of
%    points X0 and X1. Both X0 and X1 are expected to be structures with an 'a'
%    field, containing the actual numerical data. The resulting K matrix is of
%    size N0 x N1, where N0 is the number of rows of XO and N1 the number of
%    rows of X1.
%
% BE CAREFUL: 
%    
%    stk_make_matcov(MODEL, X0) and stk_makematcov(MODEL, X0, X0) are NOT 
%    equivalent if model.lognoisevariance exists (in the first case, the
%    noise variance is added on the diagonal of the covariance matrix).

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

function [K, P] = stk_make_matcov(model, x0, x1, pairwise)
stk_narginchk(2, 4);

x0 = double(x0);
if (nargin > 2), x1 = double(x1); end

%=== guess which syntax has been used based on the second input arg

switch nargin
    
    case 2, % stk_make_matcov(model, x0)
        make_matcov_auto = true;
        pairwise = false;
        
    case 3, % stk_make_matcov(model, x0, x1)
        make_matcov_auto = false;
        pairwise = false;
        
    case 4, % stk_make_matcov(model, x0, ?, pairwise)
        make_matcov_auto = isempty(x1);
        
    otherwise
        error('Incorrect number of input arguments.');
end

if isfield(model, 'Kx_cache'), % handle the case where 'Kx_cache' is present    
    
    if ~pairwise,
        if make_matcov_auto,
            K = model.Kx_cache(x0, x0);
        else
            K = model.Kx_cache(x0, x1);
        end
    else
        if make_matcov_auto,
            idx = sub2ind(size(model.Kx_cache), x0, x0);
            K = model.Kx_cache(idx);
        else
            idx = sub2ind(size(model.Kx_cache), x0, x1);
            K = model.Kx_cache(idx);
        end        
    end
    
else % handle the case where the covariance matrix must be computed
    
    %=== blocking parameters for parallel computing
    
    % If the size of the covariance matrix to be computed is smaller than
    % MIN_SIZE_FOR_BLOCKING, we don't even consider using parfor.
    MIN_SIZE_FOR_BLOCKING = 500^2;
    
    % If it is decided to use parfor, the number of blocks will be chosen
    % in such a way that blocks smaller than MIN_BLOCK_SIZE are never used
    MIN_BLOCK_SIZE = 100^2;
    
    %=== number of covariance values to be computed ?
    
    N0 = size(x0, 1);
    
    if make_matcov_auto,
        if ~pairwise,
            N = N0 * N0;
        else
            N = N0;
        end
    else
        N1 = size(x1, 1);
        if ~pairwise
            N = N0 * N1;
        else
            if N1 ~= N0,
                errmsg = 'x0 and x1 should have the same number of lines.';
                stk_error(errmsg, 'InconsistentDimensions');
            end
            N = N0;
        end
    end
    
    %=== decide whether parallel computing should be used or not
        
    % note: parallelization is not implemented in the "pairwise" case
    
    if pairwise || (N < MIN_SIZE_FOR_BLOCKING) || ~stk_is_pct_installed(),
        ncores = 1; % do not use parallel computing
    else
        ncores = max(1, matlabpool('size'));
        % note: matlabpool('size') returns 0 if the PCT is not started
    end
    
    %=== call the subfunction that does the actual computations
    
    if make_matcov_auto,

        % FIXME: avoid computing twice each off-diagonal term
        if ncores == 1, % shortcut when parallelization is not used
            K = feval(model.covariance_type, model.param, x0, x0, -1, pairwise);
        else
            K = stk_make_matcov_auto_parfor(model, x0, ncores, MIN_BLOCK_SIZE);
        end
        
        if isfield(model, 'lognoisevariance'),            
            if ~pairwise,
                K = K + stk_noisecov(size(K,1), model.lognoisevariance);
            else
                stk_error('Not implemented yet.', 'NotImplementedYet');
            end
        end
    else
        if ncores == 1, % shortcut when parallelization is not used
            K = feval(model.covariance_type, model.param, x0, x1, -1, pairwise);
        else
            K = stk_make_matcov_inter_parfor(model, x0, x1, ncores, MIN_BLOCK_SIZE);
        end
    end
    
end

%=== compute the regression functions

if nargout > 1, P = stk_ortho_func(model, x0); end

end

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared model, model2, x0, x1, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc
%! n0 = 20; n1 = 10; d = 4;
%! model = stk_model('stk_materncov_aniso', d); model.order = 1;
%! model2 = model; model2.lognoisevariance = log(0.01);
%! x0 = stk_sampling_randunif(n0, d);
%! x1 = stk_sampling_randunif(n1, d);

%!error [KK, PP] = stk_make_matcov();
%!error [KK, PP] = stk_make_matcov(model);
%!test  [Ka, Pa] = stk_make_matcov(model, x0);           % (1)
%!test  [Kb, Pb] = stk_make_matcov(model, x0, x0);       % (2)
%!test  [Kc, Pc] = stk_make_matcov(model, x0, x1);       % (3)
%!error [KK, PP] = stk_make_matcov(model, x0, x1, pi);

%!test  assert(isequal(size(Ka), [n0 n0]));
%!test  assert(isequal(size(Kb), [n0 n0]));
%!test  assert(isequal(size(Kc), [n0 n1]));

%!test  assert(isequal(size(Pa), [n0 d + 1]));
%!test  assert(isequal(size(Pb), [n0 d + 1]));
%!test  assert(isequal(size(Pc), [n0 d + 1]));

%!% In the noiseless case, (1) and (2) should give the same results
%!test  assert(isequal(Kb, Ka));

%!% In the noisy case, however... 
%!test  [Ka, Pa] = stk_make_matcov(model2, x0);           % (1')
%!test  [Kb, Pb] = stk_make_matcov(model2, x0, x0);       % (2')
%!error assert(isequal(Kb, Ka));

%!% The second output depends on x0 only => should be the same for (1)--(3)
%!test  assert(isequal(Pa, Pb));
%!test  assert(isequal(Pa, Pc));

%!test %% use of Kx_cache, with matrices
%! model2 = model;
%! [model2.Kx_cache, model2.Px_cache] = stk_make_matcov(model, x0);
%! idx = [1 4 9];
%! [K1, P1] = stk_make_matcov(model,  x0(idx, :));
%! [K2, P2] = stk_make_matcov(model2, idx');
%! assert(stk_isequal_tolrel(K1, K2));
%! assert(stk_isequal_tolrel(P1, P2));
