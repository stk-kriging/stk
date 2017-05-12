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

% Process threshold_mode argument
model = get_model (crit0);
if (nargin < 3) || (isempty (threshold_mode))
    if stk_isnoisy (model)
        threshold_mode = 'best quantile';
    else
        threshold_mode = 'best evaluation';
    end
end

% Process threshold_value argument
if nargin < 4
    threshold_value = [];
end
if ~ isempty (threshold_value) && ~ strcmp (threshold_mode, 'user-defined')
    stk_error (['Argument threshold_mode must be set to ''user-' ...
        'defined'' or [] when threshold_value is provided.'], ...
        'IncompatibleArguments');
end

% Process threshold_quantile_order argument
if nargin < 5
    threshold_quantile_order = 0.5;
end

% Create object
crit.threshold_mode = threshold_mode;
crit.threshold_value = threshold_value;
crit.threshold_quantile_order = threshold_quantile_order;
crit.threshold_quantile_value = 0;  % private
crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);

% Compute threshold value if needed
crit = set_threshold_mode (crit, threshold_mode);

% Check threshold_quantile_order's value and compute threshold_quantile_value
crit = set_threshold_quantile_order (crit, threshold_quantile_order);

end % function


%!shared M
%! M = stk_model ()

%!test  crit = stk_sampcrit_thresholdbasedoptim ();
%!test  crit = stk_sampcrit_thresholdbasedoptim (M, 'minimize');
%!test  crit = stk_sampcrit_thresholdbasedoptim (M, 'minimize', 'best quantile');
%!test  crit = stk_sampcrit_thresholdbasedoptim (M, 'minimize', 'user-defined', 3.4);
%!test  crit = stk_sampcrit_thresholdbasedoptim (M, 'minimize', 'best quantile', [], 0.3);
%!error crit = stk_sampcrit_thresholdbasedoptim (M, 'minimize', 'best quantile', [], 0.3, 0.12345);
