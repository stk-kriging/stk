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
    (model, goal, threshold_mode, threshold_value)

if nargin > 4
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin == 0,  % No input argument case
    
    crit0 = stk_sampcrit_modelbased ();
    crit1 = stk_sampcrit_singleobjoptim ();
    
    crit.threshold_mode = 'best evaluation';
    crit.threshold_value = NaN;
    
    crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);
    return
end

% Create parent objects
crit0 = stk_sampcrit_modelbased (model);
crit1 = stk_sampcrit_singleobjoptim (goal);

if nargin < 3  % Two input arguments: use 'best evaluation' as a default
    
    % FIXME: use 'best quantile' in case of noisy evaluations
    crit.threshold_mode = 'best evaluation';
    crit.threshold_value = NaN;
    crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);
    crit = set_threshold_value (crit);
    
elseif nargin < 4  % Three input arguments: threshold_mode has been specified
    
    crit.threshold_mode = threshold_mode;
    crit.threshold_value = NaN;
    crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);
    crit = set_threshold_value (crit);
    
else  % Four input argument: user-defined threshold
    
    if (~ isempty (threshold_mode)) ...
            && (~ strcmp (threshold_mode, 'user-defined'))
        
        stk_error (['Argument threshold_mode must be set to ''user-' ...
            'defined'' or [] when threshold_value is provided.'], ...
            'IncompatibleArguments');
        
    end
    
    crit.threshold_mode = 'user-defined';
    crit.threshold_value = threshold_value;
    crit = class (crit, 'stk_sampcrit_thresholdbasedoptim', crit0, crit1);
    
end

end % function


%!test crit = stk_sampcrit_thresholdbasedoptim ();
