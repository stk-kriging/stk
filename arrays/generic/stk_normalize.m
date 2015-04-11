% STK_NORMALIZE normalizes a dataset to [0; 1] ^ DIM

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function [y, a, b] = stk_normalize (x, box)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% read argument x
x = double (x);
[n d] = size (x);

if nargin < 2,
    xmin = min (x, [], 1);
    xmax = max (x, [], 1);
else
    if ~ isequal (size (box), [2 d])
        errmsg = sprintf ('box should have size [2 d], with d=%d.', d);
        stk_error (errmsg, 'IncorrectSize');
    else
        xmin = box(1, :);
        xmax = box(2, :);
    end
end

b = 1 ./ (xmax - xmin);
a = - xmin .* b;

y = repmat (a, n, 1) + x * diag (b);

end % function stk_normalize


%!shared x, box, y1, y2, y3, y4
%! n = 5;  box = [2; 3];  x = box(1) + diff (box) * rand (n, 1);

%!error  y1 = stk_normalize ();
%!test   y2 = stk_normalize (x);
%!test   y3 = stk_normalize (x, box);
%!error  y4 = stk_normalize (x, box, log (2));

%!test assert (~ any ((y2 < -10 * eps) | (y2 > 1 + 10 * eps)));
%!test assert (~ any ((y3 < -10 * eps) | (y3 > 1 + 10 * eps)));
