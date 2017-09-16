% @STK_SAMPCRIT_EQI/SET [overload base function]

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
    
    case 'model'
        
        if isempty (value)
            
            crit.model = [];
            crit.current_minimum = +inf;
            
        else
            
            crit.model = value;
            crit.current_minimum = compute_current_minimum (crit);
            
        end
        
    case 'quantile_order'
        
        order = double (value);
        
        if (~ isscalar (order)) || (order < 0) || (order > 1)
            stk_error (['The value of property ''quantile_order'' ' ...
                'must be a scalar between 0 and 1.'], 'InvalidArgument');
        else
            crit.quantile_order = order;
            try
                crit.quantile_value = norminv (order);
            catch
                crit.quantile_value = - sqrt (2) * erfcinv (2 * order);  % CG#09
            end
        end
        
        if ~ isempty (crit.model)
            crit.current_minimum = compute_current_minimum (crit);
        end
        
    case 'point_batch_size'
        
        if ischar (value)
            
            crit.point_batch_size = str2func (value);
            
        elseif isa (value, 'function_handle')
            
            crit.point_batch_size = value;
            
        else  % Last possibility: a fixed numeric value
            
            point_batch_size = double (value);
            
            if (~ isscalar (point_batch_size)) || (point_batch_size <= 0) ...
                    || (point_batch_size ~= floor (point_batch_size))
                stk_error ('Incorrect ''point_batch_size'' value', ...
                    'InvalidArgument');
            else
                crit.point_batch_size = point_batch_size;
            end
            
        end
        
    case 'current_minimum'  % Visible but read-only property
        
        stk_error (sprintf (['Property ''current_minimum'' is read-only.' ...
            '\n\nWHY: The value of ''current_minimum'' is computed '      ...
            'automatically from the input data of the model.']),          ...
            'ReadOnlyProperty');
        
    case 'quantile_value'  % Hidden, read-only property
        
        stk_error (sprintf (['Property ''quantile_value'' is read-only.' ...
            '\n\nWHY: The value of ''quantile_value'' is computed '      ...
            'automatically from the value of ''quantile_order''.']),     ...
            'ReadOnlyProperty');
        
    otherwise
        
        errmsg = sprintf ('There is no property named %s', propname);
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function


function m = compute_current_minimum (crit)

xi = get_input_data (crit.model);

if isempty (xi)
    m = +inf;
else
    zp = stk_predict (crit.model, xi);
    q = zp.mean + crit.quantile_value * (sqrt (zp.var));
    m = min (q);
end

end % function
