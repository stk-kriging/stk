% SET [overloaded base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function x = set (x, propname, value)

icol = get_column_number (x.colnames, propname);

switch icol
    
    case -3 % 'rownames'
        x.rownames = value;
        
    case -2 % 'colnames'
        x.colnames = value;
            
    case - 1 % set entire array
        if isequal (size(x.data), size(value))
            x.data = value;
        else
            error ('Incorrect size');
        end
        
    otherwise
        if isequal (size(value), [size(x.data, 1) 1])
            x.data(:, icol) = value;
        else
            error ('Incorrect size');
        end
        
end

end % function get
