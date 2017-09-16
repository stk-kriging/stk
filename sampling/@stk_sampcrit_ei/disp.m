% @STK_SAMPCRIT_EI/DISP [overload base function]
%
% See also: disp

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
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

function disp (crit)

loose_spacing = stk_disp_isloose ();

fprintf ('<%s>\n', stk_sprintf_sizetype (crit));

if loose_spacing
    fprintf ('|\n');
end

if isempty (crit.model)
    % Uninstantiated sampling criterion
    model_str = '--  (not instantiated)';
else
    % Instantiated sampling criterion
    model_str = sprintf ('<%s>', stk_sprintf_sizetype (crit.model));
end

fprintf ('|             model:  %s\n', model_str);
fprintf ('|   current_minimum:  %s\n', num2str (crit.current_minimum));

if loose_spacing
    fprintf ('|\n\n');
end

end % function
