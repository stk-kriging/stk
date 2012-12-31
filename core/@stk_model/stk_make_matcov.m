% STK_MAKE_MATCOV computes a covariance matrix (and a design matrix).
%
% CALL: [K, P] = stk_make_matcov(MODEL, X0)
%
%    computes the covariance matrix K and the design matrix P for the model
%    MODEL at the set of points X0. For a set of N points on a DIM-dimensional
%    space of factors, X0 is expected to be a structure whose field 'a' contains
%    an N x DIM matrix. As a result, a matrix K of size N x N and a matrix P of
%    size N x L are obtained, where L is the number of regression functions in
%    the linear part of the model; e.g., L = 1 if MODEL.randomprocess.priormean.param
%    is zero (ordinary kriging). [FIXME: obsolete doc]
%
% CALL: K = stk_make_matcov(MODEL, X0, X1)
%
%    computes the covariance matrix K for the model MODEL between the sets of
%    points X0 and X1. Both X0 and X1 are expected to be structures with an 'a'
%    field, containing the actual numerical data. The resulting K matrix is of
%    size N0 x N1, where N0 is the number of rows of XO.a and N1 the number of
%    rows of X1.a.
%
% BE CAREFUL:
%
%    stk_make_matcov(MODEL, X0) and stk_makematcov(MODEL, X0, X0) are NOT
%    equivalent, unless model.noise is an stk_nullcov (the noise variance is 
%    added on the diagonal of the covariance matrix).

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

function [K, P] = stk_make_matcov(model, x0, x1, pairwise)

if (nargin > 1) && isstruct(x0), x0 = x0.a; end
if (nargin > 2) && isstruct(x1), x1 = x1.a; end

%=== guess which syntax has been used based on the second input arg

switch nargin

    case 1, % stk_make_matcov(model)
        make_matcov_auto = true;
        pairwise = false;
        x0 = model.observations.x;

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

switch  model.domain.type

    case 'discrete',

        switch model.private.config.use_cache

            case true,  % handle the case where a 'Kx_cache' field is present
                        % NB: this feature only works with a discrete domain
			    if ~pairwise,
			        if make_matcov_auto,
            			K = model.private.Kx_cache(x0, x0);
			        else
        			    K = model.private.Kx_cache(x0, x1);
					end
			    else
			        if make_matcov_auto,
			            idx = sub2ind(size(model.Kx_cache), x0, x0);
			            K = model.private.Kx_cache(idx);
			        else
			            idx = sub2ind(size(model.Kx_cache), x0, x1);
			            K = model.private.Kx_cache(idx);
			        end        
			    end

            case false, % handle the case where the covariance matrix must be computed
                error('feature not implemented yet'); % FIXME
        end
        
    case 'continuous'

		% Blocking parameters for parallel computing
		% a) If the size of the covariance matrix to be computed is smaller than
		%    MIN_SIZE_FOR_BLOCKING, we don't even consider using parfor.
		% b) If it is decided to use parfor, the number of blocks will be chosen
		%    in such a way that blocks smaller than MIN_BLOCK_SIZE are never used
		MIN_SIZE_FOR_BLOCKING = 500^2;
		MIN_BLOCK_SIZE = 100^2;
    
	    % Number of covariance values to be computed ?	    
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

        % Decide whether parallel computing should be used     
    	% note: parallelization is not implemented in the "pairwise" case
        if pairwise || (N < MIN_SIZE_FOR_BLOCKING) || ~stk_is_pct_installed(),
            ncores = 1; % do not use parallel computing
        else
            ncores = max(1, matlabpool('size'));
            % note: matlabpool('size') returns 0 if the PCT is not started
        end
        
        % covariance function
        cov = model.randomprocess.priorcov;
        
        % Call the subfunction that does the actual computation
        if make_matcov_auto,
            
            % FIXME: avoid computing twice each off-diagonal term
            if ncores == 1, % parallelization is not used
	            K = feval(cov, x0, x0, -1, pairwise);
            else
                K = stk_make_matcov_auto_parfor(cov, x0, ncores, MIN_BLOCK_SIZE);
            end
            
            % add noise
            K = K + feval(model.noise.cov, x0, x0, -1, pairwise);
            
        else
            
            if ncores == 1, % parallelization is not used
	            K = feval(cov, x0, x1, -1, pairwise);
            else
                K = stk_make_matcov_inter_parfor(cov, x0, x1, ncores, MIN_BLOCK_SIZE);
            end
            
        end
        
end % switch model.domain.type

% Compute the regression functions
if nargout > 1, P = feval(model.randomprocess.priormean, x0); end

end

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared model, model2, x0, x1, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc
%! n0 = 20; n1 = 10; d = 4;
%! model = stk_model('stk_materncov_aniso', d); 
%! model.randomprocess.priormean = stk_lm('affine');
%! model2 = model;
%! model2.noise.cov = stk_homnoisecov(0.1^2); % std 0.1
%! x0 = stk_sampling_randunif(n0, d);
%! x1 = stk_sampling_randunif(n1, d);

%!error [KK, PP] = stk_make_matcov();
%!test  [KK, PP] = stk_make_matcov(model);
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

% FIXME: outdated tests related to Kx_cache/Px_cache

% %!test %% use of Kx_cache, with .a fields
% %! model2 = model;
% %! [model2.Kx_cache, model2.Px_cache] = stk_make_matcov(model, x0);
% %! idx = [1 4 9];
% %! [K1, P1] = stk_make_matcov(model,  struct('a', x0.a(idx, :)));
% %! [K2, P2] = stk_make_matcov(model2, struct('a', idx'));
% %! assert(stk_isequal_tolrel(K1, K2));
% %! assert(stk_isequal_tolrel(P1, P2));

% %!test %% use of Kx_cache, with matrices
% %! x0 = x0.a;
% %! model2 = model;
% %! [model2.Kx_cache, model2.Px_cache] = stk_make_matcov(model, x0);
% %! idx = [1 4 9];
% %! [K1, P1] = stk_make_matcov(model,  x0(idx, :));
% %! [K2, P2] = stk_make_matcov(model2, idx');
% %! assert(stk_isequal_tolrel(K1, K2));
% %! assert(stk_isequal_tolrel(P1, P2));
