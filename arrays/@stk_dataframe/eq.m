% EQ [overload base function]

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

function y = eq(x1, x2)

y = bsxfun(@eq, x1, x2);

end % function

%!test  stk_test_dfbinaryop(@eq, floor(3*rand(7, 2)), floor(3*rand(7, 2)));
%!test  stk_test_dfbinaryop(@eq, floor(3*rand(7, 2)), 1.0);
%!error stk_test_dfbinaryop(@eq, floor(3*rand(7, 2)), floor(3*rand(7, 3)));
