% DISP [overload base function]
%
% Example:
%    format short
%    x = [1 1e6 rand; 10 -1e10 rand; 100 1e-22 rand];
%    disp (stk_dataframe (x))

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function s = stk_sprintf (x, verbosity, data_col_width)

if (nargin < 2) || (isempty (verbosity)),
    verbosity = stk_options_get ('stk_dataframe', 'disp_format');
end
if ~ ismember (verbosity, {'basic', 'verbose'})
    errmsg = 'verbosity should be ''basic'' or ''verbose''.';
    stk_error (errmsg, 'InvalidArgument');
end

if (nargin < 3) || (isempty (data_col_width)),
    data_col_width = [];
end

s = sprintf_table_ (x.data, x.colnames, x.rownames, data_col_width);

if strcmp (verbosity, 'verbose'),
    
    spstr = stk_options_get ('stk_dataframe', 'disp_spstr');
    
    s = char (...
        '.info =', horzcat (spstr, stk_sprintf_info (x)), ...
        '.colnames =', horzcat (spstr, stk_sprintf_colnames (x)), ...
        '.rownames =', horzcat (spstr, stk_sprintf_rownames (x)), ...
        '.data =', horzcat (repmat (spstr, size (s, 1), 1), s));
    
end

end % function stk_sprintf

%#ok<*CTCH>


function s = sprintf_table_ (x, colnames, rownames, data_col_width)

x = double (x);
[n, d] = size (x);

if (n == 0) || (d == 0)
    
    s = '[] (empty)';
    
else
    
    if (nargin < 2) || isempty (data_col_width)
        try
            switch get (0, 'Format')
                case 'short'
                    data_col_width = 8;
                case 'long'
                    data_col_width = 16;
                otherwise
                    % FIXME: handle other formatting modes...
                    data_col_width = 8;
            end
        catch
            % Property 'Format' doesn't exist in Octave 3.2.x
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
    
    for j = 1:d,
        
        xx = stk_sprintf_colvect (x(:, j), data_col_width);
        Lxx = size (xx, 2);
        
        vn = colnames{j};
        if isempty (vn),
            vn = repmat('-', 1, Lxx);
        end
        
        L = max (length (vn), Lxx);
        s = [s [sprintf('% *s', L, vn);   % variable name
            repmat(' ', n, L - Lxx) xx]]; % formatted data
        
        if j < d,
            % column separator
            s = [s repmat(' ', nb_rows,  nb_spaces_colsep)];
        end
        
    end % for
    
end % if

end % function sprintf_table_


%!shared x fmt
%! try % doesn't work on old Octave versions, nevermind
%!   fmt = get (0, 'Format');
%! catch
%!   fmt = nan;
%! end
%! x = stk_dataframe (rand (3, 2));

%!test format rat;      disp (x);
%!test format long;     disp (x);
%!test format short;    disp (x);
%!     if ~isnan (fmt), set (0, 'Format', fmt); end

%!test disp (stk_dataframe (zeros (0, 1)))
%!test disp (stk_dataframe (zeros (0, 2)))
