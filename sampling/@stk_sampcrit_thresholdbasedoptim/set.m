% SET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function crit = set (crit, propname, value)

switch propname
    
    case 'model'
        crit = set_model (crit, value);
        
    case 'input_data'
        stk_error ('Property ''input_data'' is read-only.', ...
            'ReadOnlyProperty');
        
    case 'output_data'
        stk_error ('Property ''output_data'' is read-only.', ...
            'ReadOnlyProperty');
        
    case 'goal'
        crit = set_goal (crit, value);
        
    case 'threshold_mode'
        crit = set_threshold_mode (crit, value);
        
    case 'threshold_value'
        crit = set_threshold_value (crit, value);

    case 'threshold_quantile_order'
        crit = set_threshold_quantile_order (crit, value);

    otherwise
        errmsg = sprintf ('There is no field named %s', propname);
        stk_error (errmsg, 'InvalidArgument');
        
end

end % function
