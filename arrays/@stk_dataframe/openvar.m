% OPENVAR [overload base function]

% Copyright Notice
%
%    Copyright (C) 2016 SUPELEC
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

function openvar (varname, x)

try
    x_val = array2table (double (x));
    x_val.Properties.RowNames = x.rownames;
    if ~ isempty (x.colnames)
        x_val.Properties.VariableNames = x.colnames;
    end
    x_name = sprintf ('%s__CONVERTED_TO_TABLE', varname);
catch
    x_val = double (x);
    x_name = sprintf ('%s__CONVERTED_TO_DOUBLE', varname);
end

show_warning = stk_options_get ('stk_dataframe', 'openvar_warndlg');

if show_warning
    
    w_msg = sprintf (['Viewing the content of stk_dataframe objects in the ' ...
        'Variable Editor directly is not possible.\n\n'...
        'A temporary variable named %s will be now created in your base ' ...
        'workspace, making it possible for you to explore the data ' ...
        'contained in %s using the Variable Editor.\n\n' ...
        'DO NOT EDIT this temporary variable, as the modifications will ' ...
        'not be copied back to the original variable %s.\n\n' ...
        'This warning will only be shown once per session.'], ...
        x_name, varname, varname);
    
    warndlg (w_msg, 'Converting stk_dataframe object', 'modal');
    
    stk_options_set ('stk_dataframe', 'openvar_warndlg', false);
end

assignin ('base', x_name, x_val);
openvar (x_name)

end