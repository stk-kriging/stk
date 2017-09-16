% STK_PRINTF [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function s = stk_sprintf (x, verbosity, data_col_width)

if (nargin < 2) || (isempty (verbosity))
    verbosity = stk_options_get ('stk_dataframe', 'disp_format');
end

if ~ ismember (verbosity, {'basic', 'verbose'})
    errmsg = 'verbosity should be ''basic'' or ''verbose''.';
    stk_error (errmsg, 'InvalidArgument');
end

if (nargin < 3) || (isempty (data_col_width))
    data_col_width = [];
end

if isempty (x)
    
    spstr = stk_options_get ('stk_dataframe', 'disp_spstr');
    
    if strcmp (verbosity, 'verbose')
        
        s = char (...
            '.colnames =', horzcat (spstr, stk_sprintf_colnames (x)), ...
            '.rownames =', horzcat (spstr, stk_sprintf_rownames (x)), ...
            '.data =', horzcat (spstr, '<', stk_sprintf_sizetype (x.data), '>'));
        
    else
        
        [n, d] = size (x);
        
        s = sprintf ('Empty data frame with %d rows and %d columns', n, d);
        
        if d > 0 && ~ isempty (x.colnames)
            s = char (s, ...
                sprintf ('  with .colnames = %s', stk_sprintf_colnames (x)));
        elseif n > 0 && ~ isempty (x.rownames)
            s = char (s, ...
                sprintf ('  with .rownames = %s', stk_sprintf_rownames (x)));
        end
    end
    
else  % x is not empty
    
    s = sprintf_table_ (x.data, x.colnames, x.rownames, data_col_width);
    
    if strcmp (verbosity, 'verbose')
        
        spstr = stk_options_get ('stk_dataframe', 'disp_spstr');
        
        s = char (...
            '.colnames =', horzcat (spstr, stk_sprintf_colnames (x)), ...
            '.rownames =', horzcat (spstr, stk_sprintf_rownames (x)), ...
            '.data =', horzcat (repmat (spstr, size (s, 1), 1), s));
        
    elseif isempty (s)
        
        disp toto
        
    end
    
end

end % function

%#ok<*CTCH>


function s = sprintf_table_ (x, colnames, rownames, data_col_width)

x = double (x);
[n, d] = size (x);

if (n == 0) || (d == 0)
    
    s = '[] (empty)';
    
else
    
    if (nargin < 2) || isempty (data_col_width)
        switch stk_disp_getformat ()
            case 'short'
                data_col_width = 8;
            case 'long'
                data_col_width = 16;
            otherwise
                % FIXME: handle other formatting modes...
                data_col_width = 8;
        end
    end
    
    % column names
    if (nargin < 3) || isempty (colnames)
        colnames = repmat ({''}, 1, d);
    end
    
    % row names
    if (nargin < 4) || isempty (rownames)
        rownames = repmat ({''}, n, 1);
    end
    b = cellfun (@isempty, rownames);
    rownames(b) = repmat({'*'}, sum (b), 1);
    rownames = fliplr (char (cellfun ...
        (@fliplr, rownames, 'UniformOutput', false)));
    
    nb_spaces_colsep = 2;
    
    nb_rows = n + 1;  % + 1 for the header
    
    s = repmat ('', nb_rows, 1); %#ok<*AGROW>
    
    s = [s [repmat(' ', 1, size(rownames, 2)); rownames]];
    
    % column separator between row names and the first data column
    s = [s repmat(' :', nb_rows,  1) ...
        repmat(' ', nb_rows,  nb_spaces_colsep)];
    
    for j = 1:d
        
        xx = stk_sprintf_colvect (x(:, j), data_col_width);
        Lxx = size (xx, 2);
        
        vn = colnames{j};
        if isempty (vn)
            vn = repmat('-', 1, Lxx);
        end
        
        L = max (length (vn), Lxx);
        s = [s [sprintf('% *s', L, vn);   % variable name
            repmat(' ', n, L - Lxx) xx]]; % formatted data
        
        if j < d
            % column separator
            s = [s repmat(' ', nb_rows,  nb_spaces_colsep)];
        end
        
    end % for
    
end % if

end % function


%!shared x, fmt
%! fmt = stk_disp_getformat ();
%! x = stk_dataframe (rand (3, 2));

%!test format rat;    disp (x);
%!test format long;   disp (x);
%!test format short;  disp (x);  format (fmt);

%!test disp (stk_dataframe (zeros (0, 1)))
%!test disp (stk_dataframe (zeros (0, 2)))
