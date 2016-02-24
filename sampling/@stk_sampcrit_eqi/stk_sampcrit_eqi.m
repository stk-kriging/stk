% STK_SAMPCRIT_EQI ...  FIXME: Missing documentation

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%
%    Author:  Tom Assouline  <tom.assouline@supelec.fr>

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

function crit = stk_sampcrit_eqi (varargin)

crit0 = stk_sampcrit_thresholdbasedoptim (varargin{:});
crit = class (struct (), 'stk_sampcrit_eqi', crit0);

% In EQI we are working with quantiles
crit = set_threshold_mode (crit, 'best quantile');

end % function
