% MLDIVIDE [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function y = mldivide (x1, x2)

if isa (x1, 'stk_dataframe')
    
    x1_data = x1.data;
    rownames = x1.colnames;
    
    if isa (x2, 'stk_dataframe')  % both are stk_dataframe objects
        
        x2_data = x2.data;
        colnames = x2.colnames;
        
    else   % x1 is an stk_dataframe object, but not x2
        
        x2_data = x2;
        colnames = {};
        
    end
    
else  % x2 is an stk_dataframe object, but x1 is not
    
    x1_data = x1;
    
    x2_data = x2.data;
    colnames = x2.colnames;
    
    if isscalar (x1)  % special case
        rownames = x2.rownames;
    else
        rownames = {};
    end
    
end

y = stk_dataframe (x1_data \ x2_data, colnames, rownames);

end % function


%!test
%! x1_data = [57 7; 2 0];
%! x1 = stk_dataframe (x1_data, {'x' 'y'}, {'a'; 'b'});
%! x2_data = [8 7; 2 0];
%! x2 = stk_dataframe (x2_data, {'w' 'z'}, {'a'; 'b'});
%! y = x2 \ x1;
%! assert (stk_isequal_tolabs (y, ...
%!     stk_dataframe ([1 0; 7 1], {'x'; 'y'}, {'w'; 'z'})));


% Special case: division by a scalar

%!shared x_data, x, y_data, y
%! x_data = [3 3; 6 3; 9 12];
%! y_data = [1 1; 2 1; 3 4];
%! x = stk_dataframe (x_data, {'x' 'y'}, {'a'; 'b'; 'c'});

%!test y = 3 \ x;
%!assert (isequal (y, stk_dataframe (y_data, {'x' 'y'}, {'a'; 'b'; 'c'})));

%!error y = x \ 3;
