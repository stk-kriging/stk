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
%! x1 = stk_dataframe (rand (3, 2), {'a'; 'b'}, {'x' 'y' 'z'});
%! x2 = stk_dataframe (rand (3, 4), {'u'; 'v'; 'w'; 'z'}, {'x' 'y' 'z'});
%! y = x1 \ x2;
%! assert (isequal (y, ...
%!     stk_dataframe (x1.data \ x2.data, {'u'; 'v'; 'w'; 'z'}, {'a'; 'b'})));


% Special case: division by a scalar

%!shared x, y
%! x = stk_dataframe (rand (3, 2), {'x' 'y'}, {'a'; 'b'; 'c'});

%!test y = 3 \ x;
%!assert (isequal (y, stk_dataframe (3 \ x.data, {'x' 'y'}, {'a'; 'b'; 'c'})));

%!error y = x \ 3;
