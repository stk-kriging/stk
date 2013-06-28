% GET_COLUMN_INDICATOR [STK internal]

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

function b = get_column_indicator(x, s)

b = strcmp(s, x.vnames);

% Note: b is empty is x.vnames is empty (no column names)

if ~any(b)
    
    if ~strcmp(s, 'a') % the special case s == 'a' is dealt with below
        
        if ~strcmp(s, 'v') % the special case s == 'v' is dealt with below
            
            errmsg = sprintf('There is no variable named %s.', s);
            stk_error(errmsg, 'UnknownVariable');
        
        else % special case s == 'v' (legacy feature)
            
            b = strcmp('var', x.vnames);
            
            if any(b)
                
                warning(sprintf(['There is no variable named ''v''.\n' ...
                    ' => Assuming that you''re an old STK user trying to ' ...
                    'get the kriging variance.'])); %#ok<WNTAG,SPWRN>
                
            else
                
                stk_error('There is no variable named v.', 'UnknownVariable');
                
            end
            
        end
        
    else % special case s == 'a' (legacy feature)
        
        b = strcmp('mean', x.vnames);
        
        if any(b)
            
            warning(sprintf(['There is no variable named ''a''.\n' ...
                ' => Assuming that you''re an old STK user trying to ' ...
                'get the kriging mean.'])); %#ok<WNTAG,SPWRN>
            
        else
            
            warning(sprintf(['There is no variable named ''a''.\n' ...
                ' => Assuming that you''re an old STK user trying to ' ...
                'get the entire dataframe.'])); %#ok<WNTAG,SPWRN>
            
            b = true(1, size(x, 2));
            
        end
        
    end
    
end

end % function get_column_indicator
