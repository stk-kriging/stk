% STK_FILLDIST computes the fill distance of a set of points
%
% CALL: FD = stk_filldist(X, BOX)
%
%    computes the fill distance FD of the dataset X in the hyper-rectangle
%    BOX, using the computational-geometric algorithm of L. Pronzato and
%    W. G. Muller [1]. Recall that
%
%       D = max_{Y in BOX} min_{1 <= i <= n} norm(X(i,:) - Y),         (1)
%
%    where norm(.) denotes the Euclidean norm in R^d. Optimal designs with
%    respect to the fill distance are sometimes called "minimax" designs
%    (see, e.g., [2]).
%
% CALL: FD = stk_filldist(X)
%
%    assumes that the fill distance is to be computed with respect to the
%    hyperrectangle BOX = [0; 1]^d.
%
% CALL: FD = stk_filldist(X, Y)
%
%    computes the fill distance FD of X using the "test set" Y. More preci-
%    sely, if X and Y are respectively n x d and m x d, then
%
%       FD = max_{1 <= j <= m} min_{1 <= i <= n} norm(X(i,:) - Y(j,:)),
%
%    If Y is dense enough in some subset BOX of R^d, then FD should be close
%    to the actual fill distance of X in BOX.
%
% CALL: [FD, YMAX] = stk_filldist(...)
%
%    also returns the point YMAX where the maximal distance is attained.
%
% NOTE:
%
%    stk_filldist is actually a wrapper around stk_filldist_discretized and
%    stk_filldist_exact. Which function to call is guessed based on the number
%    of rows of the second argument. Because of that, the test set Y is required
%    to have at least 3 rows.
%
% REFERENCES
%
%   [1] Luc Pronzato and Werner G. Muller, "Design of computer
%       experiments: space filling and beyond", Statistics and Computing,
%       22(3):681-701, 2012.
%
%   [2] Mark E. Johnson, Leslie M. Moore and Donald Ylvisaker, "Minimax
%       and maximin distance designs", Journal of Statistical Planning
%       and Inference, 26(2):131-148, 1990.
%
% See also: stk_dist, stk_mindist, stk_filldist_exact, stk_filldist_discretized

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect <julien.bect@supelec.fr>

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

function [fd, ymax] = stk_filldist(x, arg2)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

x = double(x);

if nargin == 1, % defaults: "exact" over [0; 1]^d
    
    default_box = repmat([0; 1], 1, size(x, 2));
    fd = stk_filldist_exact(x, default_box);
    
else

    arg2 = double(arg2);
    
    ny = size(arg2, 1);
    
    if ny == 2, % arg2 is interpreted as a box
        
        [fd, ymax] = stk_filldist_exact(x, arg2);
        
    elseif ny > 2, % arg2 is interpreted a discrete test set
        
        [fd, idx_max] = stk_filldist_discr_mex(x, arg2);
        ymax = arg2(idx_max, :);
        
    else
        
        errmsg = 'Incorrect size for argument #2: nb rows > 1 expected.';
        stk_error(errmsg, 'InvalidArgument');
        
    end
            
end % if

end % function stk_filldist


%%
% Check that both double-precision matrices and stk_dataframe objects are accepted

%!test %%% exact
%! d = 3; x = rand(7, d); box = repmat([0; 1], 1, d);
%! fd1 = stk_filldist(x, box);
%! fd2 = stk_filldist(stk_dataframe(x), stk_dataframe(box));
%! assert(stk_isequal_tolabs(fd1, fd2));

%!test %%% discretized
%! d = 3; x = rand(7, d); y = rand(20, d);
%! fd1 = stk_filldist(x, y);
%! fd2 = stk_filldist(stk_dataframe(x), stk_dataframe(y));
%! assert(stk_isequal_tolabs(fd1, fd2));

%%
% fd = 0 if X = Y (discretized filldist)

%!test
%! n = 5; % must be bigger than 2
%! for dim = 1:10,
%!     x = rand(n, dim);
%!     fd = stk_filldist(x, x);
%!     assert(stk_isequal_tolabs(fd, 0.0));
%! end

%%
% One point in the middle of [0; 1]^d (exact & discretized filldist)

%!test %%% exact
%! for dim = 1:6,
%!     x = 0.5 * ones(1, dim);
%!     fd = stk_filldist(x); % [0; 1]^d is the default box
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%!test %%% discretized
%! for dim = 1:6,
%!     x  = 0.5 * ones(1, dim);
%!     y  = stk_sampling_regulargrid(2^dim, dim);  % [0; 1]^d is the default box
%!     fd = stk_filldist(x, y);
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%%
% One point in the middle of [1; 2]^d (exact filldist)

%!test
%! for dim = [1 3 7],
%!     box = repmat([1; 2], 1, dim);
%!     x = 1 + 0.5 * ones(1, dim);
%!     fd = stk_filldist(x, box);
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%%
% 20 points in [-1; 1]^3

%!test
%! dim = 3;
%! box = repmat([-1; 1], 1, dim);
%! x   = stk_sampling_randunif(20, dim, box);
%! y   = stk_sampling_regulargrid(3^dim, dim, box);
%! fd1 = stk_filldist(x, box);
%! fd2 = stk_filldist(x, y);
%! assert(fd1 >= fd2 - 10 * eps);

%%
% One point at the origin, BOX = [0; 1]^d

%!test %%% exact
%! for dim = [1 3 7],
%!     x = zeros(1, dim);
%!     [fd, ymax] = stk_filldist_exact(x);
%!     assert(stk_isequal_tolabs(fd, sqrt(dim)));
%!     assert(stk_isequal_tolabs(ymax, ones(1, dim)));
%! end

%!test %%% discretized
%! for dim = [1 3 7],
%!     x = zeros(1, dim);
%!     y = stk_sampling_regulargrid(3^dim, dim);
%!     [fd, ymax] = stk_filldist(x, y);
%!     assert(stk_isequal_tolabs(fd, sqrt(dim)));
%!     assert(stk_isequal_tolabs(ymax, ones(1, dim)));
%! end
