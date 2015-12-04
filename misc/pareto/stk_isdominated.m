% STK_ISDOMINATED returns true for dominated rows
%
% CALL: ISDOM = stk_isdominated (A, B)
%
%    returns a vector ISDOM of logicals, where ISDOM(i) is true if A(i, :)
%    is dominated by one of the rows of B. A row B(j, :) is said to
%    dominate A(i, :) if
%
%       B(j, k) <= A(i, k)    for all k in {1, 2, ..., d}
%
%    and
%
%       B(j, k) < A(i, k)     for at least one such k,
%
%    where d is the number of columns.  In other words: smaller is better.
%
% CALL: ISDOM = stk_isdominated (A, B, DO_SORTROWS)
%
%    does the same but, if DO_SORTROWS == false, assumes that the rows of
%    B are already sorted in ascending lexical order.
%
% CALL: [ISDOM, DPOS] = stk_isdominated (A, B, DO_SORTROWS)
%
%    also returns a vector DPOS such that DPOS(i) = 0 if A(i, :) is non-
%    dominated, and DPOS(i) gives the index of a row in B that dominates
%    A(i, :) otherwise.
%
% See also: sortrows, stk_paretofind, stk_dominatedhv

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

function [isdom, dpos, Bsnd] = stk_isdominated (A, B, do_sortrows)

A = double (A);
B = double (B);

if nargin < 3,
    do_sortrows = true;
end

if do_sortrows,
    ndpos = stk_paretofind (B);
    Bsnd = B(ndpos, :);
end

if nargout < 2
    isdom = stk_isdominated_mex (A, Bsnd);
else
    [isdom, drank] = stk_isdominated_mex (A, Bsnd);
    if do_sortrows,
        dpos = zeros (size (drank));
        dpos(isdom) = ndpos(drank(isdom));
    end
end

end % function


%!test
%! A = [1 3 2];
%! B = [0 0 0];
%! [isdom, dpos] = stk_isdominated (A, B);
%! assert (isdom == 1);
%! assert (dpos == 1);

%!test
%! A = [1 3 2];
%! B = [0 0 3];
%! [isdom, dpos] = stk_isdominated (A, B);
%! assert (isdom == 0);
%! assert (dpos == 0);

%!test
%! A = [1 3 2];
%! B = [0 0 0; 0 0 3];
%! [isdom, dpos] = stk_isdominated (A, B);
%! assert (isdom == 1);
%! assert (dpos == 1);

%!test
%! A = [1 3 2];
%! B = [0 0 3; 0 0 0];
%! [isdom, dpos] = stk_isdominated (A, B);
%! assert (isdom == 1);
%! assert (dpos == 2);

%!test
%! A = [1 3 2; 1 0 1; -1 0 0; 1 3 2];
%! B = [1 0 0; 0 0 3; 0 0 0];
%! [isdom, dpos] = stk_isdominated (A, B);
%! assert (isequal (isdom, logical ([1; 1; 0; 1])));
%! assert (isequal (dpos, [3; 3; 0; 3]));
