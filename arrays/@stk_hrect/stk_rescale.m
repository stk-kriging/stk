% STK_RESCALE [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function [x, a, b] = stk_rescale (x, box1, box2)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Read argument x
x_data = double (x);
d = size (x_data, 2);

if isempty (box1)
    
    % Speed up the case where box1 is empty
    b1 = 1;
    a1 = 0;
    
else
    
    % Ensure that box1 is an stk_hrect object
    if ~ isa (box1, 'stk_hrect')
        box1 = stk_hrect (box1);
    end
    
    % Extract lower/upper bounds for box1
    box1_data = double (box1.stk_dataframe);
    if ~ isequal (size (box1_data), [2 d])
        errmsg = sprintf ('box1 should have size [2 d], with d=%d.', d);
        stk_error (errmsg, 'IncorrectSize');
    end
    
    % Scale to [0; 1] (xx --> zz)
    xmin = box1_data(1, :);
    xmax = box1_data(2, :);
    b1 = 1 ./ (xmax - xmin);
    a1 = - xmin .* b1;
    
end

if isempty (box2)
    
    % Speed up the case where box2 is empty
    b2 = 1;
    a2 = 0;
    
else
    
    % Ensure that box2 is an stk_hrect object
    if ~ isa (box2, 'stk_hrect')
        box2 = stk_hrect (box2);
    end
    
    % Extract lower/upper bounds for box2
    box2_data = double (box2.stk_dataframe);
    if ~ isequal (size (box2_data), [2 d])
        errmsg = sprintf ('box2 should have size [2 d], with d=%d.', d);
        stk_error (errmsg, 'IncorrectSize');
    end
    
    % scale to box2 (zz --> yy)
    ymin = box2_data(1, :);
    ymax = box2_data(2, :);
    b2 = ymax - ymin;
    a2 = ymin;
    
end

b = b2 .* b1;
a = a2 + a1 .* b2;

x(:) = bsxfun (@plus, a, bsxfun (@times, x_data, b));

end % function

%#ok<*CTCH>


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
