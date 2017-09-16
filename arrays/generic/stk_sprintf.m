% STK_SPRINTF prints the content of an array into a string

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

% verbosity will be ignored, but let's check that it's a legal value anyway
if (nargin > 1) && (~ ismember (verbosity, {'basic', 'verbose'}))
    errmsg = 'verbosity should be ''basic'' or ''verbose''.';
    stk_error (errmsg, 'InvalidArgument');
end

% Only the case of numeric array is handled here
if ~ isnumeric (x)
    errmsg = sprintf ('Incorrect argument type: %s', class (x));
    stk_error (errmsg, 'IncorrectType');
end

x = double (x);
[n, d] = size (x);

if (n == 0) || (d == 0)
    
    s = '[] (empty)';
    
else
    
    if (nargin < 2) || isempty (data_col_width)
        switch stk_disp_getformat ()
            case 'short'
                data_col_width = 6;
            case 'long'
                data_col_width = 16;
            otherwise
                % FIXME: handle other formatting modes...
                data_col_width = 10;
        end
    end
    
    nb_spaces_colsep = 2;
    
    s = repmat ('', n, 1); %#ok<*AGROW>
    
    for j = 1:d
        xx = stk_sprintf_colvect (x(:, j), data_col_width);
        s = [s xx]; % formatted data
        if j < d
            % column separator
            s = [s repmat(' ', n,  nb_spaces_colsep)];
        end
        
    end % for
    
end % if

end % function

%#ok<*CTCH>
