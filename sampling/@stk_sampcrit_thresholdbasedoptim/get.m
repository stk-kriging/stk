% GET [overload base function]

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

function value = get (crit, propname)

switch propname
    
    case 'model'
        value = get_model (crit);
        
    case 'input_data'
        value = get_input_data (crit);
        
    case 'output_data'
        value = get_output_data (crit);
        
    case 'goal'
        value = get_goal (crit);
        
    case 'threshold_mode'
        value = get_threshold_mode (crit);
        
    case 'threshold'
        value = get_threshold (crit);
        
    otherwise
        errmsg = sprintf ('There is no field named %s', propname);
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function
