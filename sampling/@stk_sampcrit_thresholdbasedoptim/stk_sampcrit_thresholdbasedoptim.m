% STK_SAMPCRIT_THRESHOLDBASEDOPTIM ...

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

function crit = stk_sampcrit_thresholdbasedoptim ...
    (model, goal, threshold_mode, threshold_value, threshold_quantile_order)

if nargin > 5  
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin == 0,  % No input argument case
    
    crit0 = stk_sampcrit_modelbased ();
    crit1 = stk_sampcrit_singleobjoptim ();
    
    crit.threshold_mode = 'best evaluation';
    crit.threshold_value = NaN;
    crit.threshold_quantile_order = 0.5;
    crit.threshold_quantile_value = 0;  % private
    
    crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);
    return
end

% Create parent objects
crit0 = stk_sampcrit_modelbased (model);
crit1 = stk_sampcrit_singleobjoptim (goal);

% Default value for property threshold_mode
model = get_model (crit0);
if model.lognoisevariance == -inf
    crit.threshold_mode = 'best evaluation';
else
    crit.threshold_mode = 'best quantile';
end

% Create object with default properties
crit.threshold_value = NaN;
crit.threshold_quantile_order = 0.5;
crit.threshold_quantile_value = 0;  % private
crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);

if nargin >= 3
    % Process threshold_mode argument
    if (~ isempty (threshold_mode))
        crit = set_threshold_mode (crit, threshold_mode);
    end
    
    if nargin >= 4
        % Process threshold_value argument
        if ~ isempty (threshold_value)
            if ~ strcmp (threshold_mode, 'user-defined')
                stk_error (['Argument threshold_mode must be set to ''user-' ...
                    'defined'' or [] when threshold_value is provided.'], ...
                    'IncompatibleArguments');
            end
            crit = set_threshold_value (crit, threshold_value);
        end
        
        % Process threshold_quantile_order argument
        if nargin >= 5
            crit = set_threshold_quantile_order ...
                (crit, threshold_quantile_order);
        end
    end
end

end % function


%!test crit = stk_sampcrit_thresholdbasedoptim ();
