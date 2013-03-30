% DOUBLE [FIXME: missing doc...]

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

function xdata = double(x)

xdata = double(x.data);

end % function double

%!test
%! u = rand(4, 3);
%! x = stk_dataframe(u);
%! v = double(x);
%! assert (strcmp(class(v), 'double') && isequal(v, u))

%!test
%! u = (rand(4, 3) < 0.5);
%! x = stk_dataframe(u);
%! v = double(x);
%! assert (strcmp(class(v), 'double') && isequal(v, double(u)))

%!test
%! u = uint8(rand(4, 3) * 5)
%! x = stk_dataframe(u);
%! v = double(x);
%! assert (strcmp(class(v), 'double') && isequal(v, double(u)))
