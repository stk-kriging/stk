% APPLY maps a function to the rows or columns of a dataframe.

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
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

function varargout = apply (x, dim, F, u)

if nargin == 4
    uu = {u};
else
    uu = {};
end

varargout = cell (1, max (1, nargout));

if dim == 1
    % act along columns
    [varargout{:}] = feval (F, x.data, uu{:}, 1);
else
    if dim ~= 2,
        stk_error ('Incorrect dimension specifier', 'IncorrectDimSpec');
    else
        % act along rows (less usual)
        [varargout{:}] = feval (F, x.data, uu{:}, 2);
    end
end

end % function

%!shared x, t, u
%! t = rand (3, 2);
%! x = stk_dataframe (t);

%!test u = apply (x, 1, @sum);
%!assert (isequal (u, sum (t, 1)))
%!test u = apply (x, 2, @sum);
%!assert (isequal (u, sum (t, 2)))
%!error u = apply (x, 3, @sum);

%!test u = apply (x, 1, @min, []);
%!assert (isequal (u, min (t, [], 1)))
%!test u = apply (x, 2, @min, []);
%!assert (isequal (u, min (t, [], 2)))
%!error u = apply (x, 3, @min, []);

%!test
%! t = [1; 3; 2];
%! x = stk_dataframe (t);
%! [M, k] = apply (x, 1, @max, []);
%! assert ((M == 3) && (k == 2));
