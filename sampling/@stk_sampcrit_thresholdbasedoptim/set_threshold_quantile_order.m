% SET_THRESHOLD_QUANTILE_ORDER ...

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

function crit = set_threshold_quantile_order (crit, value)

% Convert to double if possible (instead of checking with isnumeric)
value = double (value);

if (~ isscalar (value)) || (value < 0) || (value > 1)
    stk_error (['The value of property ''threshold_quantile_order'' ' ...
        'must be a scalar between 0 and 1.'], 'InvalidArgument');
else
    crit.threshold_quantile_order = value;
    crit.threshold_quantile_value = norminv (value);
end

end % function
