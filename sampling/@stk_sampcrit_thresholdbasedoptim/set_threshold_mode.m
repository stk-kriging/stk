% SET_THRESHOLD_MODE ...

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

function crit = set_threshold_mode (crit, threshold_mode)

switch threshold_mode
    
    case 'user-defined'
        crit.threshold_mode = 'user-defined';
        
    case {'best evaluation', 'best quantile'}
        crit.threshold_mode = threshold_mode;
        crit = set_threshold (crit);
        
    otherwise
        if ischar (threshold_mode)
            errmsg = sprintf (['Incorrect threshold_mode ' ...
                'value: %s.'], threshold_mode);
        else
            errmsg = sprintf (['Incorrect type for ' ...
                'threshold_mode: %s.'], class (threshold_mode));
        end
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function
