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

nb_spaces_before = 4;
spstr = repmat(' ', 1, nb_spaces_before); %#ok<*AGROW>

[n, d] = size(x.data);

fprintf('stk_dataframe object\n\n');
fprintf(' .colnames:\n');

if isempty(x.colnames)
    
    if d == 1,
        fprintf('%sstk_dataframe with 1 unnamed variable.\n', spstr);
    else
        fprintf('%sstk_dataframe with %d unnamed variables.\n', spstr, d);
    end
    
else
    
    if d == 1,
        fprintf('%sstk_dataframe with 1 variable: ', spstr);
        fprintf('%s\n', x.colnames{1});
    else
        fprintf('%sstk_dataframe with %d variables: ', spstr, d);
        for j = 1:(d-1),
            fprintf('%s, ', x.colnames{j});
        end
        fprintf('%s\n', x.colnames{end});
    end
    
end

fprintf(' .rownames:\n');

if isempty(x.rownames)
    
        fprintf('%sstk_dataframe with %d unnamed elements.\n', spstr, n);  
else
    
        fprintf('%sstk_dataframe with %d elements: ', spstr, n);
        for j = 1:(n-1),
            fprintf('%s, ', x.rownames{j});
        end
        fprintf('%s\n', x.rownames{end});
    
end

fprintf(' .data/.a:\n');
nb_spaces_colsep = 2;
if n>0,
    
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
            % Property 'Format' doesn't exist in Octave 3.2.x
            max_width = 6;
        end
    end
    
    has_colnames = ~isempty(x.colnames);
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
            
            vn = x.colnames{j};
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
    
    disp(str);
else
    fprintf('\tempty dataframe\n')
end % if

end % function disp


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
