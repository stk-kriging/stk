% STK_DATAFRAME constructs a dataframe

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function x = stk_dataframe(x0, colnames, rownames)

if nargin > 3,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

info = struct('creator', 'default constructor');

if nargin == 0  % default constructor
    x = struct('data', zeros(0, 1), 'colnames', {{}}, 'rownames', {{}}, 'info', info);    
else    
    x = struct('data', x0, 'colnames', {{}}, 'rownames', {{}}, 'info', info);
end   

x = class(x, 'stk_dataframe');

if nargin >= 2,
    x = set(x, 'colnames', colnames);
end

if nargin >= 3,
    x = set(x, 'rownames', rownames);
end

end % function stk_dataframe

%!shared x y

%!test % default constructor
%! x = stk_dataframe();   

%!test
%! y = stk_dataframe(rand(3, 2));
%! assert (isa (y, 'stk_dataframe') && isequal(size(y), [3 2]))

%!test
%! y = stk_dataframe(rand(3, 2), {'x', 'y'});
%! assert (isa (y, 'stk_dataframe') && isequal(size(y), [3 2]))

%!test
%! y = stk_dataframe(rand(3, 2), {'x', 'y'}, {'a', 'b', 'c'});
%! assert (isa (y, 'stk_dataframe') && isequal(size(y), [3 2]))
