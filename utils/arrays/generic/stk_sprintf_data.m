% STK_SPRINTF_DATA prints the content of an array into a string

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function s = stk_sprintf_data (x, max_width, colnames, rownames)

if ~ isnumeric (x)
    
    errmsg = sprintf ('Incorrect argument type: %s', class (x));
    stk_error (errmsg, 'IncorrectType');
    
else
    
    x = double (x);
    [n, d] = size (x);
    
    if (n == 0) || (d == 0)
        
        s = '[] (empty)';
        
    else
                
        if (nargin < 2) || isempty (max_width)
            try
                switch get (0, 'Format')
                    case 'short'
                        max_width = 6;
                    case 'long'
                        max_width = 16;
                    otherwise
                        % FIXME: handle other formatting modes...
                        max_width = 10;
                end
            catch
                % Property 'Format' doesn't exist in Octave 3.2.x
                max_width = 6;
            end
        end
        
        if (nargin < 3) || isempty (colnames)
            colnames = repmat ({repmat('-', 1, max_width)}, 1, d);
        end
        
        if nargin < 4,
            rownames = {};
        end
        
        nb_spaces_colsep = 2;
        
        nb_rows = n + 1;  % + 1 for the header
        
        s = repmat ('', nb_rows, 1); %#ok<*AGROW>
        
        % first columns: row names
        if isempty (rownames)
            rownames = repmat('*', n, 1);
        else
            rownames = char (rownames);
        end
        
        s = [s [repmat(' ', 1, size(rownames, 2)); rownames]];
        
        % column separator between row names and the first data column
        s = [s repmat(' :', nb_rows,  1) ...
            repmat(' ', nb_rows,  nb_spaces_colsep)];
        
        for j = 1:d,
            
            xx  = stk_sprintf_colvect (x(:, j), max_width);
            
            vn = colnames{j};
            Lxx = size (xx, 2);
            L = max (length (vn), Lxx);
            s = [s [sprintf('% *s', L, vn);  % variable name
                repmat(' ', n, L - Lxx) xx]];    % formatted data
            
            if j < d,
                % column separator
                s = [s repmat(' ', nb_rows,  nb_spaces_colsep)];
            end
            
        end % for
        
    end % if
    
end % function stk_sprintf_data
