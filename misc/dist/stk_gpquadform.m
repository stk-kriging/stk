% STK_GPQUADFORM   [experimental, not part of public API yet... UAYOR!]
%
% CALL: Q = stk_gpquadform (X, Y, RX, RY)
%
%    computes a matrix Q, whose entries Q(i,j) are given by a Gibbs-
%    Paciorek quadratic form 
%
%       Q(i,j) = \sum_{k = 1}^d (X(i,k) - Y(j,k))^2 / R(i,j,k)^2,
%
%    where
%
%       R(i,j,k)^2 = RX(i,k)^2 + RY(i,k)^2,
%
%    assuming that
%
%     * X and RX have size [nX d],
%     * Y and RY have size [nY d].

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function Q = stk_gpquadform (x, y, rx, ry, pairwise)

if nargin > 5,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% read argument #1
if isstruct (x),
    x = x.a;
end

% read argument #2
if isstruct (y),
    y = y.a;
end

% read argument #4
if nargin < 4,
    if isempty (y)
        ry = rx;
    else
        errmsg = 'Not enough input arguments.';
        stk_error (errmsg, 'NotEnoughInputArgs');
    end
else
    if (isempty (y)) && (~ isempty (ry)) && (~ isequal (rx, ry))
        errmsg = 'ry should be empty or equal to rx';
        stk_error (errmsg, 'InvalidArgument');
    end
end
        

% read argument #5
if nargin < 5,
    pairwise = false;
else
    if ~ islogical (pairwise)
        errmsg = 'Argument ''pairwise'' should be either true or false.';
        stk_error (errmsg, 'TypeMismatch');
    end
end

if pairwise,
    if isempty (y),
        Q = zeros (size (x, 1), 1);
    else
        Q = stk_gpquadform_pairwise (x, y, rx, ry);
    end
else
    if isempty (y),
        Q = stk_gpquadform_matrixx (x, rx);
    else
        Q = stk_gpquadform_matrixy (x, y, rx, ry);
    end
end

end % function


%%%%%%%%%
% TESTS %
%%%%%%%%%

%!shared x, y, z, rx, ry, rz
%! x = rand(5, 2);  rx = rand(5, 2) + 1;
%! y = rand(6, 2);  ry = rand(6, 2) + 1;
%! z = rand(5, 3);  rz = rand(5, 3) + 1;

%%
% Check that an error is raised when sizes are incompatible

%!error Q = stk_gpquadform(x, ry, y, ry)
%!error Q = stk_gpquadform(x, rz, y, ry)
%!error Q = stk_gpquadform(x, rx, y, rx)
%!error Q = stk_gpquadform(x, rx, y, rz)
%!error Q = stk_gpquadform(x, rx, z, ry)

%%
% Check that ".a" structures are accepted

%!test
%! Dxy1 = stk_gpquadform(x, y, rx, ry);
%! Dxy2 = stk_gpquadform(struct('a', x), struct('a', y), rx, ry);
%! assert(stk_isequal_tolabs(Dxy1, Dxy2));

%%
% Tests with r = 1/sqrt(2)

%!shared x, y, z, rx, ry, rz
%! x = zeros (11, 5);  rx = 1/sqrt(2) * ones (11, 5);
%! y = zeros (13, 5);  ry = 1/sqrt(2) * ones (13, 5);
%! z = ones  ( 7, 5);  rz = 1/sqrt(2) * ones ( 7, 5);

%!test
%! Qx = stk_gpquadform(x, [], rx);
%! assert(isequal(Qx, zeros(11)));

%!test
%! Qxx = stk_gpquadform(x, x, rx, rx);
%! assert(isequal(Qxx, zeros(11)));

%!test
%! Qxy = stk_gpquadform(x, y, rx, ry);
%! assert(isequal(Qxy, zeros(11, 13)));

%!test
%! Qzz = stk_gpquadform(z, [], rz);
%! assert(isequal(Qzz, zeros(7)));

%!test
%! Qxz = stk_gpquadform(x, z, rx, rz);
%! assert(stk_isequal_tolabs(Qxz, 5 * ones(11, 7)));

%%
% Tests with a random r

%!test
%! x = randn(5, 3);  rx = 1 + rand(5, 3);
%! y = randn(5, 3);  ry = 1 + rand(5, 3);
%! Q1 = stk_gpquadform(x, y, rx, ry, true); % pairwise
%! Q2 = stk_gpquadform(x, y, rx, ry, false);
%! assert(isequal(size(Q1), [5 1]));
%! assert(isequal(size(Q2), [5 5]));
%! assert(stk_isequal_tolabs(Q1, diag(Q2)));

%!test
%! x = randn(5, 3);  rx = 1 + rand(5, 3);
%! Q1 = stk_gpquadform(x, [], rx, [], true); % pairwise
%! assert(stk_isequal_tolabs(Q1, zeros(5, 1)));
%! Q1 = stk_gpquadform(x, x, rx, rx, true); % pairwise
%! assert(stk_isequal_tolabs(Q1, zeros(5, 1)));


%%
% Tests with r = 2

%!shared x, y, z, rx, ry, rz
%! x = zeros (11, 5);  rx = 2 * ones (11, 5);
%! y = zeros (13, 5);  ry = 2 * ones (13, 5);
%! z = ones  ( 7, 5);  rz = 2 * ones ( 7, 5);

%!test
%! Qx = stk_gpquadform(x, [], rx);
%! assert(isequal(Qx, zeros(11)));

%!test
%! Qxx = stk_gpquadform(x, x, rx, rx);
%! assert(isequal(Qxx, zeros(11)));

%!test
%! Qxy = stk_gpquadform(x, y, rx, ry);
%! assert(isequal(Qxy, zeros(11, 13)));

%!test
%! Qzz = stk_gpquadform(z, [], rz);
%! assert(isequal(Qzz, zeros(7)));

%!test
%! Qxz = stk_gpquadform(x, z, rx, rz);
%! assert(stk_isequal_tolabs(Qxz, 5/8 * ones(11, 7)));
