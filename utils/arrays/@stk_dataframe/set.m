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
     
    case -4 % 'info'
        x.info = value;
    
    case -3 % 'rownames'
        if isempty (value)
            x.rownames = {};
        else
            n1 = size (x.data, 1);
            n2 = length (value);
            if ~ iscell (value) && (isequal (size (value), [1 n2]) ...
                    || isequal (value, [n2 1])),               
                stk_error ('value should be a vector-shaped cell array.');
            else
                value = value(:);
                b = cellfun (@isempty, value);
                value(b) = repmat ({''}, sum (b), 1);
                if n2 <= n1
                    x.rownames = [value; repmat({''}, n1 - n2, 1)];
                else
                    x.rownames = value;
                    x.data = [x.data; nan(n2 - n1, size(x.data, 2))];
                end
            end
        end
        
    case -2 % 'colnames'
        if isempty (value)
            x.colnames = {};
        else
            d1 = size (x.data, 2);
            d2 = length (value);
            if ~ iscell (value) && (isequal (size (value), [1 d2]) ...
                    || isequal (value, [d2 1])),
                stk_error ('value should be a vector-shaped cell array.');
            else
                value = reshape (value, 1, d2);
                b = cellfun (@isempty, value);
                value(b) = repmat ({''}, 1, sum (b));
                if d2 <= d1
                    x.colnames = [value repmat({''}, 1, d1 - d2)];
                else
                    x.colnames = value;
                    x.data = [x.data nan(size(x.data, 1), d2 - d1)];
                end
            end
        end
            
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

end % function set
