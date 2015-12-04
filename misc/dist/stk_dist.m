% STK_DIST computes a matrix of (Euclidean) distances
%
% CALL: D = stk_dist(X, Y)
%
%    computes the matrix of distances between X and Y. More precisely, if
%    X is an nX x d matrix, and Y an nY x d matrix, the D is an nX x nY
%    matrix with
%
%       D_{i,j} = norm(X(i,:) - Y(j,:)),
%
%    where norm(.) denotes the Euclidean norm in R^d.
%
% See also: stk_mindist, stk_filldist, norm

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>

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

function D = stk_dist(x, y, pairwise)

if nargin > 3,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% read argument #1
x = double(x);

% read argument #2
if nargin < 2,
    y = [];
else
    y = double(y);
end

% read argument #3
if nargin < 3,
    pairwise = false;
else
    if ~islogical(pairwise)
        errmsg = 'Argument ''pairwise'' should be either true or false.';
        stk_error(errmsg, 'TypeMismatch');
    end
end

if pairwise,
    if isempty(y),
        D = zeros(size(x, 1), 1);
    else
        D = stk_dist_pairwise (x, y);
        %D = sqrt (sum ((x - y) .^ 2, 2));  % The MEX-file is usually faster
    end
else
    if isempty(y),
        D = stk_dist_matrixx(x);
    else
        D = stk_dist_matrixy(x, y);
    end
end

end % function

%%
% Check that an error is raised in nargin is neither 1 nor 2

%!error stk_dist();
%!error stk_dist(0, 0, 0);
%!error stk_dist(0, 0, 0, 0);

%%
% Check that an error is raised when the number of columns differs

%!error stk_dist(0, ones(1, 2));
%!error stk_dist(eye(3), ones(1, 2));
%!error stk_dist(ones(2, 1), zeros(2));

%%
% Test with some simple matrices

%!shared x, y, z
%! x = zeros(11, 5);
%! y = zeros(13, 5);
%! z = ones(7, 5);

%!test
%! Dx = stk_dist(x);
%! assert(isequal(Dx, zeros(11)));

%!test
%! Dxx = stk_dist(x, x);
%! assert(isequal(Dxx, zeros(11)));

%!test
%! Dxy = stk_dist(x, y);
%! assert(isequal(Dxy, zeros(11, 13)));

%!test
%! Dzz = stk_dist(z, z);
%! assert(isequal(Dzz, zeros(7)));

%!test
%! Dxz = stk_dist(x, z);
%! assert(stk_isequal_tolabs(Dxz, sqrt(5)*ones(11, 7)));

%!test
%! x = randn(5,3);
%! y = randn(5,3);
%! D1 = stk_dist(x, y, true); % pairwise
%! D2 = stk_dist(x, y);
%! assert(stk_isequal_tolabs(D1, diag(D2)));

%!test
%! x = randn(5,3);
%! D1 = stk_dist(x, [], true); % pairwise
%! assert(stk_isequal_tolabs(D1, zeros(5, 1)));
%! D1 = stk_dist(x, x, true); % pairwise
%! assert(stk_isequal_tolabs(D1, zeros(5, 1)));
