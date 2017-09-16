% @STK_SAMPCRIT_EI/SET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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
    
    case 'model'  % Modifiable property
        
        if isempty (value)
            
            crit.model = [];
            crit.current_minimum = +inf;
            
        else
            
            % Set 'model' property
            crit.model = value;
            
            % Compute current minimum
            zi = get_output_data (crit.model);
            if isempty (zi)
                crit.current_minimum = +inf;
            else
                n = size (zi, 1);
                crit.current_minimum = min (zi);
            end
            
        end % if
        
    case 'current_min'  % Read-only property
        
        stk_error (sprintf (['Property ''current_min'' is read-only.\n\n' ...
            'WHY: The value of ''current_min'' is computed automatically ' ...
            'from the input data of the model.']), 'ReadOnlyProperty');
        
    otherwise
        
        errmsg = sprintf ('There is no property named %s', propname);
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function
