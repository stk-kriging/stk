% SET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
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
            n2 = numel (value);
            
            if iscell (value) && n2 >= n1
                x.rownames = reshape (value, n2, 1);
            else
                stk_error (sprintf (['The value of ''rownames'' should be ' ...
                    'a cell array with %d elements.'], n1), 'InvalidArgument');
            end
            
            b = cellfun (@isempty, x.rownames);
            nb = sum (b);
            if nb > 0
                x.rownames(b) = repmat ({''}, nb, 1);
            end
            if n2 > n1
                x.data = [x.data; nan(n2 - n1, size(x.data, 2))];
            end
        end
        
    case -2 % 'colnames'
        
        if isempty (value)
            x.colnames = {};
        else
            d1 = size (x.data, 2);
            d2 = numel (value);
            
            if iscell (value) && d2 >= d1
                x.colnames = reshape (value, 1, d2);
            else
                stk_error (sprintf (['The value of ''colnames'' should be ' ...
                    'a cell array with %d elements.'], d1), 'InvalidArgument');
            end
            
            b = cellfun (@isempty, x.colnames);
            nb = sum (b);
            if nb > 0
                x.colnames(b) = repmat ({''}, 1, nb);
            end
            if d2 > d1
                x.data = [x.data nan(size(x.data, 1), d2 - d1)];
            end
        end
        
    case - 1 % set entire array
        
        x = set_data (x, value);
        
    otherwise
        if isequal (size(value), [size(x.data, 1) 1])
            x.data(:, icol) = value;
        else
            error ('Incorrect size');
        end
        
end

end % function
