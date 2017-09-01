% MRDIVIDE [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function y = mrdivide (x1, x2)

if isa (x1, 'stk_dataframe')
    x1_data = x1.data;
    x1_rownames = x1.rownames;
else
    x1_data = x1;
    x1_rownames = {};
end

if isa (x2, 'stk_dataframe')
    x2_data = x2.data;
    x2_rownames = x2.rownames;
else
    x2_data = x2;
    x2_rownames = {};
end

y = stk_dataframe (x1_data / x2_data, x2_rownames, x1_rownames);

end % function


%!test
%! x1 = stk_dataframe (rand (2, 3), {'x' 'y' 'z'}, {'a'; 'b'});
%! x2 = stk_dataframe (rand (4, 3), {'x' 'y' 'z'}, {'u'; 'v'; 'w'; 'z'});
%! y = x1 / x2;
%! assert (isequal (y, ...
%!     stk_dataframe (x1.data / x2.data, {'u'; 'v'; 'w'; 'z'}, {'a'; 'b'})));
