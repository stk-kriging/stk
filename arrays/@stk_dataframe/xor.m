% XOR [overload base function]

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

function y = xor(x1, x2)

y = bsxfun(@xor, x1, x2);

end % function

%!shared x, y, z
%! x = floor (3 * rand (7, 2));
%! y = floor (3 * rand (7, 2));
%! z = floor (3 * rand (7, 3));

%!test  stk_test_dfbinaryop ('xor', x, y);
%!test  stk_test_dfbinaryop ('xor', x, 1.0);
%!error stk_test_dfbinaryop ('xor', x, z);
