% STK_NORMALIZE [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
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

function [x, a, b] = stk_normalize (x, box)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 2,
    box = [];
end

% Read argument x
x_data = double (x);
d = size (x_data, 2);

% Ensure that box is an stk_hrect object
if ~ isa (box, 'stk_hrect')
    if isempty (box)
        box = stk_boundingbox (x_data);  % Default: bounding box
    else
        box = stk_hrect (box);
    end
end

% Read argument box
box_data = double (box.stk_dataframe);
if ~ isequal (size (box_data), [2 d])
    errmsg = sprintf ('box should have size [2 d], with d=%d.', d);
    stk_error (errmsg, 'IncorrectSize');
end

xmin = box_data(1, :);  % lower_bounds
xmax = box_data(2, :);  % upper_bounds

b = 1 ./ (xmax - xmin);
a = - xmin .* b;

x(:) = bsxfun (@plus, a, x_data * diag (b));

end % function


%!shared x, box, y1, y2, y3, y4
%! n = 5;  box = stk_hrect ([2; 3]);
%! x = 2 + rand (n, 1);

%!error  y1 = stk_normalize ();
%!test   y2 = stk_normalize (x);
%!test   y3 = stk_normalize (x, box);
%!error  y4 = stk_normalize (x, box, log (2));

%!test assert (~ any ((y2 < -10 * eps) | (y2 > 1 + 10 * eps)));
%!test assert (~ any ((y3 < -10 * eps) | (y3 > 1 + 10 * eps)));
