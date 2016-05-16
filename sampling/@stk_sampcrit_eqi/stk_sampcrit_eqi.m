% STK_SAMPCRIT_EQI ...  FIXME: Missing documentation

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec & EDF R&D
%
%    Authors:  Tom Assouline, Florent Autret & Stefano Duhamel
%              Julien Bect  <julien.bect@centralesupelec.fr>

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

function crit = stk_sampcrit_eqi (model, goal, ...
    threshold_quantile_order, varargin)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% No input argument case
if nargin == 0,
    crit0 = stk_sampcrit_thresholdbasedoptim ();
    crit0 = set_threshold_mode (crit0, 'best quantile');
    crit = class (struct (), 'stk_sampcrit_eqi', crit0);
    return
end

% Create parent object
if nargin < 3
    % threshold_quantile_order not provided
    crit0 = stk_sampcrit_thresholdbasedoptim (model, goal, 'best quantile');
else
    % threshold_quantile_order provided
    crit0 = stk_sampcrit_thresholdbasedoptim ...
        (model, goal, 'best quantile', [], ...
        threshold_quantile_order, varargin{:});
end

% Create stk_sampcrit_eqi object
crit = class (struct (), 'stk_sampcrit_eqi', crit0);

end % function
