% STK_RESCALE rescales a dataset from one box to another

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

function [y, a, b] = stk_rescale (x, box1, box2)

if nargin > 3,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% read argument x
x = double (x);
[n, d] = size (x);

% read box1
if isempty (box1),
    box1 = stk_setobj_box (d);
else
    box1 = stk_setobj_box (box1);
end

% read box2
if isempty (box2),
    box2 = stk_setobj_box (d);
else
    box2 = stk_setobj_box (box2);
end

% scale to [0; 1] (xx --> zz)
xmin = box1.lb;
xmax = box1.ub;
b1 = 1 ./ (xmax - xmin);
a1 = - xmin .* b1;

% scale to box2 (zz --> yy)
zmin = box2.lb;
zmax = box2.ub;
b2 = zmax - zmin;
a2 = zmin;

b = b2 .* b1;
a = a2 + a1 .* b2;
y = repmat (a, n, 1) + x * diag (b);

end % function stk_rescale


%!shared x
%! x = rand (10, 4);
%! y = stk_rescale (x, [], []);
%! assert (stk_isequal_tolabs (x, y));

%!test
%! y = stk_rescale(0.5, [], [0; 2]);
%! assert (stk_isequal_tolabs (y, 1.0));

%!test
%! y = stk_rescale (0.5, [0; 1], [0; 2]);
%! assert (stk_isequal_tolabs (y, 1.0));

%!test
%! y = stk_rescale (0.5, [0; 2], []);
%! assert (stk_isequal_tolabs (y, 0.25));

%!test
%! y = stk_rescale (0.5, [0; 2], [0; 1]);
%! assert (stk_isequal_tolabs (y, 0.25));
