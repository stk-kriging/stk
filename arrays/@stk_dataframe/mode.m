% MODE [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@centralesupelec.fr>

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

function z = mode(x, dim)

if nargin < 2, dim = 1; end

z = apply(x, dim, @mode);

end % function


%!shared x1, df1
%! x1 = floor(3 * rand(9, 3));
%! df1 = stk_dataframe(x1, {'a', 'b', 'c'});
%!assert (isequal (mode(df1),    mode(x1)))
%!assert (isequal (mode(df1, 1), mode(x1)))
%!assert (isequal (mode(df1, 2), mode(x1, 2)))
