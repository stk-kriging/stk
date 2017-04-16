% SORT [overload base]

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

function [x, i] = sort (x, dim, mode)

if ~ isa (x, 'stk_dataframe'),
    % Not what we expect: dim or mode is an stk_dataframe...
    stk_error ('x should be an stk_dataframe object here.', 'TypeMismatch');
end

if (nargin < 2) || (isempty (dim)),
    % Sort along the first non-singleton dimension
    if (size (x.data, 1) > 1)
        dim = 1;
    else
        dim = 2;
    end
elseif ~ ((dim == 1) || (dim == 2))
    stk_error ('dim sould be 1 or 2.', 'InvalidArgument');
end

if nargin < 3,
    mode = 'ascend';
end

if dim == 1,  % Sort columns
    
    [x.data, i] = sort (x.data, 1, mode);
    
    if (size (x.data, 2) > 1)
        % Row names are lost when sorting a dataframe with more than one column
        x.rownames = {};
    elseif ~ isempty (x.rownames)
        x.rownames = x.rownames(i);
    end
    
else  % Sort rows
    
    [x.data, i] = sort (x.data, 2, mode);
    
    if (size (x.data, 1) > 1)
        % Column names are lost when sorting a dataframe with more than one row
        x.colnames = {};
    elseif ~ isempty (x.colnames)
        x.colnames = x.colnames(i);
    end
    
end

end % function


%!shared x, y
%! x = stk_dataframe ([3; 2; 1], {}, {'a', 'b', 'c'});
%! y = sort (x);

%!assert (strcmp (class (y), 'stk_dataframe'))
%!assert (isequal (y.data, [1; 2; 3]))
%!assert (isequal (y.rownames, {'c'; 'b'; 'a'}))
%!assert (isequal (sort (x, []), y))
%!assert (isequal (sort (x,  1), y))
%!assert (isequal (sort (x,  2), x))
%!error sort (x, 3)
%!assert (isequal (sort (x, [], 'ascend'), y))
%!assert (isequal (sort (x,  1, 'ascend'), y))
%!assert (isequal (sort (x,  2, 'ascend'),  x))
%!error sort (x,  3, 'ascend')
%!assert (isequal (sort (x, [], 'descend'), x))
%!assert (isequal (sort (x,  1, 'descend'), x))
%!assert (isequal (sort (x,  2, 'descend'), x))
%!error sort (x,  3, 'descend')
