% DISP [overloaded base function]
%
% Example:
%    format short
%    x = [1 1e6 rand; 10 -1e10 rand; 100 1e-22 rand];
%    disp(stk_dataframe(x))

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

function disp(x, max_width)

[n, d] = size(x.data);

if n == 0,
    
    if isempty(x.vnames)
        
        if d == 1,
            fprintf('Empty stk_dataframe with 1 variable.\n');
        else
            fprintf('Empty stk_dataframe with %d variables.\n', d);
        end

    else
        
        if d == 1,
            fprintf('Empty stk_dataframe with 1 variable: ');
            fprintf('%s\n\n', x.vnames{1});
        else
            fprintf('Empty stk_dataframe with %d variables: ', d);
            for j = 1:(d-1),
                fprintf('%s, ', x.vnames{j});
            end
            fprintf('%s\n\n', x.vnames{end});
        end
        
    end
    
else
    
    if nargin < 2,
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
            % get (0, ...) doesn't work in Octave 3.2.x
            max_width = 6;
        end
    end
    
    nb_spaces_before = 1;
    nb_spaces_colsep = 2;
    
    has_colnames = ~isempty(x.vnames);
    nb_rows = n + has_colnames;
    
    str = repmat(' ', nb_rows, nb_spaces_before); %#ok<*AGROW>
    
    % first columns: row names
    if isempty(x.rownames)
        rownames = stk_sprintf_colvect(1:n);
    else
        rownames = char(x.rownames);
    end
    
    if has_colnames
        str = [str [repmat(' ', 1, size(rownames, 2)); rownames]];
    else
        str = [str rownames];
    end
    
    % column separator between row names and the first data column
    str = [str repmat(' :', nb_rows,  1) ...
        repmat(' ', nb_rows,  nb_spaces_colsep)];
    
    for j = 1:d,
        
        xx  = stk_sprintf_colvect(x.data(:, j), max_width);
        
        
        if ~has_colnames % no need for a header row in this case
            
            str = [str xx];
            
        else
            
            vn = x.vnames{j};
            Lxx = size(xx, 2);
            L = max(length(vn), Lxx);
            str = [str [sprintf('% *s', L, vn);  % variable name
                repmat(' ', n, L - Lxx) xx]];    % formatted data
            
        end
        
        if j < d,
            % column separator
            str = [str repmat(' ', nb_rows,  nb_spaces_colsep)];
        end
        
    end % for
    
    disp(str); fprintf('\n');
    
end % if

end % function disp


%!shared x fmt
%! try % doesn't work on old Octave versions, nevermind
%!   fmt = get (0, 'Format');
%! catch
%!   fmt = nan;
%! end
%! x = stk_dataframe (rand (3, 2));

%!test format short;     disp (x);
%!test format long;      disp (x);
%!test format rat;       disp (x);
%!     if ~isnan (fmt), set (0, 'Format', fmt); end

%!test disp (stk_dataframe (zeros (0, 1)))
%!test disp (stk_dataframe (zeros (0, 2)))
