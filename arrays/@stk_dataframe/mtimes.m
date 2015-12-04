% MTIMES [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function y = mtimes (x1, x2)

if isa (x1, 'stk_dataframe')
    x1_data = x1.data;
    rownames = x1.rownames;
else
    x1_data = x1;
    rownames = {};
end

if isa (x2, 'stk_dataframe')
    x2_data = x2.data;
    colnames = x2.colnames;
else
    x2_data = x2;
    colnames = {};
end

y = stk_dataframe (x1_data * x2_data, colnames, rownames);

end % function


%!shared x, y, z, w
%!
%! u = [1 3 4; 2 7 6];   % 2 x 3
%! v = [6 2; 1 7; 9 4];  % 3 x 2
%! w = [45 39; 73 77];   % u * v
%! 
%! x = stk_dataframe (u, {}, {'a'; 'b'});
%! y = stk_dataframe (v, {'c' 'd'});
%! z = x * y;
 
%!assert (isa (z, 'stk_dataframe'));
%!assert (isequal (z.data, w));
%!assert (isequal (z.rownames, x.rownames));
%!assert (isequal (z.colnames, y.colnames));
