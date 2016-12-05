% SET_THRESHOLD_VALUE ...

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

function crit = set_threshold_value (crit, threshold_value)

if nargin < 2  % Recompute threshold
    
    if strcmp (crit.threshold_mode, 'best evaluation')
        
        % Quantity of Interest = evaluation results
        QoI = get_output_data (crit);
        
    elseif strcmp (crit.threshold_mode, 'best quantile')
        
        % Quantity of Interest = quantiles
        xi = get_input_data (crit);
        if isempty (xi)
            QoI = [];
        else
            zp = stk_predict (get_model (crit), xi);
            QoI = zp.mean + crit.threshold_quantile_value * (sqrt (zp.var));
        end
        
    end
    
    if isempty (QoI)
        crit.threshold_value = nan;
    elseif get_bminimize (crit)
        crit.threshold_value = min (QoI);
    else
        crit.threshold_value = max (QoI);
    end
    
else  % Argument 'threshold' has been provided
    
    crit.threshold_value = threshold_value;
    crit.threshold_mode = 'user-defined';
    
end

end % function
