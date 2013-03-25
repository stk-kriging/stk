% DISP displays the content of a dataframe.
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
    
else
    
    if nargin < 2,
        switch get(0, 'Format')
            case 'short'
                max_width = 6;
            case 'long'
                max_width = 16;
            otherwise
                % FIXME: handle other formatting modes...
                max_width = 10;
        end
    end
    
    nb_spaces_before = 1;
    nb_spaces_colsep = 2;
    
    str = repmat(' ', n + 1,  nb_spaces_before); %#ok<*AGROW>
    
    % first columns: row names
    rownames = char(stk_get_rownames(x));
    str = [str [repmat(' ', 1, size(rownames, 2)); rownames]];
    
    % column separator
    str = [str repmat(' ', n + 1,  nb_spaces_colsep)];
    
    for j = 1:d,
        
        vn = x.vnames{j};
        xx = stk_sprintf_colvect(x.data(:, j), max_width);
        
        Lxx = size(xx, 2);
        L = max(length(vn), Lxx);
        
        str = [str [sprintf('% *s', L, vn);  % variable name
            repmat(' ', n, L - Lxx) xx]];    % formatted data
        
        if j < d,
            % column separator
            str = [str repmat(' ', n + 1,  nb_spaces_colsep)];
        end
        
    end % for
    
    disp(str); fprintf('\n');

end % if

end % function disp


%!shared x fmt
%! fmt = get(0, 'Format');
%! x = stk_dataframe(rand(3, 2));

%!test set(0, 'Format', 'short');     disp(x);
%!test set(0, 'Format', 'long');      disp(x);
%!test set(0, 'Format', 'rational');  disp(x);
%!test set(0, 'Format', fmt);

%!test disp(stk_dataframe(zeros(0, 1)))
%!test disp(stk_dataframe(zeros(0, 2)))
