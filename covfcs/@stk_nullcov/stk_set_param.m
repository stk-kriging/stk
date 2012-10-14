% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

function cov = stk_set_param(cov, propertyname, value)

errmsg = 'param is immutable for stk_nullcov objects.';

if isempty(propertyname), % "full parameter"
    
    if ~isempty(value),
        stk_error(errmsg, 'SettingImmutableParameter');
    end
    
else
    
    switch propertyname,
        
        case 'variance',
            if value ~= 0.0,
                stk_error(errmsg, 'SettingImmutableParameter');
            end
            
        case 'logvariance',
            if value ~= -Inf,
                stk_error(errmsg, 'SettingImmutableParameter');
            end
            
        otherwise,
            errmsg = sprintf('Property %s does not exist.', propertyname);
            stk_error(errmsg, 'IncorrectArgument');
            
    end % switch
    
end % if

end