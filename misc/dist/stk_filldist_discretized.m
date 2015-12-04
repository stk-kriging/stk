% STK_FILLDIST_DISCRETIZED computes the (discrete) fill distance of a set of points
%
% CALL: FD = stk_filldist_discretized(X, Y)
%
%    computes the fill distance FD of X using the "test set" Y. More precisely, if 
%    X and Y are respectively n x d and m x d, then
%
%       FD = max_{1 <= j <= m} min_{1 <= i <= n} norm(X(i,:) - Y(j,:)),
%
%    where norm(.) denotes the Euclidean norm in R^d. If Y is dense enough in some
%    subset BOX of R^d, then FD should be close to the actual fill distance of X in
%    BOX (see: stk_filldist_exact). Optimal designs with respect to the fill distance
%    are sometimes called "minimax" designs (see, e.g., [1]).
%
% CALL: [D, ARGMAX] = stk_filldist_discretized(X, Y)
%
%    also returns the value ARGMAX of the index j for which the maximum is attained.
%    (If the maximum is obtained for several values of j, the smallest is returned.)
%
% REFERENCE
%
%   [1] Mark E. Johnson, Leslie M. Moore and Donald Ylvisaker, "Minimax
%       and maximin distance designs", Journal of Statistical Planning
%       and Inference, 26(2):131-148, 1990.
%
% See also: stk_filldist, stk_filldist_exact, stk_dist, stk_mindist

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Author: Julien Bect <julien.bect@centralesupelec.fr>

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

function [fd, ymax] = stk_filldist_discretized(x, y)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

x = double(x);
y = double(y);

% call MEX-file
[fd, idx_max] = stk_filldist_discr_mex(x, y);
ymax = y(idx_max, :);

end % function


%%
% Two non-empty matrices are expected as input arguments

%!error stk_filldist_discretized(0.0)            % incorrect nb of arguments
%!error stk_filldist_discretized(0.0, 0.0, pi)   % incorrect nb of arguments
%!error stk_filldist_discretized(0.0, [])        % second arg is empty
%!error stk_filldist_discretized([], 0.0)        % first arg is empty

%%
% Check that both double-precision matrices and stk_dataframe objects are accepted

%!test
%! d = 3; x = rand(7, d); y = rand(20, d);
%! fd1 = stk_filldist_discretized(x, y);
%! fd2 = stk_filldist_discretized(stk_dataframe(x), stk_dataframe(y));
%! assert(stk_isequal_tolabs(fd1, fd2));

%%
% fd = 0 if X = Y

%!test
%! n = 5;
%! for dim = 1:10,
%!     x = rand(n, dim);
%!     fd = stk_filldist_discretized(x, x);
%!     assert(stk_isequal_tolabs(fd, 0.0));
%! end

%%
% fd = norm if nx = ny = 1

%!test
%! for dim = 1:10,
%!     x = rand(1, dim);
%!     y = rand(1, dim);
%!     fd = stk_filldist_discretized(x, y);
%!     assert(stk_isequal_tolabs(fd, norm(x - y)));
%! end

%%
% Filldist = max(dist) if ny = 1

%!test
%! n = 4;
%! for dim = 2:10,
%!     x = zeros(n, dim);
%!     y = rand(1, dim);
%!     fd = stk_filldist_discretized(x, y);
%!     assert(stk_isequal_tolabs(fd, max(stk_dist(x, y))));
%! end

%%
% One point in the middle of [0; 1]^d

%!test
%! for dim = [1 3 6],
%!     x  = 0.5 * ones(1, dim);
%!     y  = stk_sampling_regulargrid(2^dim, dim);  % [0; 1]^d is the default box
%!     fd = stk_filldist_discretized(x, y);
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%%
% One point at the origin, BOX = [0; 1]^d

%!test
%! for dim = [1 3 7],
%!     x = zeros(1, dim);
%!     y = stk_sampling_regulargrid(3^dim, dim);
%!     [fd, ymax] = stk_filldist_discretized(x, y);
%!     assert(stk_isequal_tolabs(fd, sqrt(dim)));
%!     assert(stk_isequal_tolabs(ymax, ones(1, dim)));
%! end
