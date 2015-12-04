% STK_PARETOFIND finds non-dominated rows in an array
%
% CALL: [NDPOS, DRANK] = stk_paretofind (X)
%
%    returns the indices NDPOS such that X(NDPOS, :) contains all non-
%    dominated rows of X, sorted in (ascending) lexical order. A row
%    X(i, :) is said to dominate another row X(j, :) if
%
%       X(i, k) <= X(j, k)    for all k in {1, 2, ..., d}
%
%    and
%
%       X(i, k) < X(j, k)     for at least one such k,
%
%    where d is the number of columns.  In other words: smaller is better.
%    For each row X(i, :),  DRANK(i) is equal to zero if the row is non-
%    dominated, and equal to the smallest j such that X(i, :) is dominated
%    by X(NDPOS(j), :) otherwise.
%
% See also: sortrows, stk_isdominated, stk_dominatedhv

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
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

function varargout = stk_paretofind (x)

varargout = cell (1, max (1, nargout));

[varargout{:}] = stk_paretofind_mex (double (x));

end % function


%!shared x, ndpos, drank
%! x = [     ...
%!     0  2; ...
%!     2  2; ...
%!     ];
 
%!test [ndpos, drank] = stk_paretofind (x);
%!assert (isequal (ndpos, 1));
%!assert (isequal (drank, [0; 1]));

%!shared x, ndpos, drank
%! x = [     ...
%!     3  2; ...
%!     2  2; ...
%!     ];
 
%!test [ndpos, drank] = stk_paretofind (x);
%!assert (isequal (ndpos, 2));
%!assert (isequal (drank, [1; 0]));

%!shared x, ndpos, drank
%! x = [     ...
%!     1  0; ...
%!     2  0; ...
%!     0  2; ...
%!     2  2; ...
%!     -1 3  ];

%!test [ndpos, drank] = stk_paretofind (x);
%!assert (isequal (ndpos, [5; 3; 1]));
%!assert (isequal (drank, [0; 3; 0; 2; 0]));

%!shared x, ndpos, drank
%! x = [     ...
%!     1  0; ...
%!     2  0; ...
%!     0  2; ...
%!     2  2; ...
%!     -1 3; ...
%!     -1 4; ...
%!     2  2  ];

%!test [ndpos, drank] = stk_paretofind (x);
%!assert (isequal (ndpos, [5; 3; 1]));
%!assert (isequal (drank, [0; 3; 0; 2; 0; 1; 2]));
