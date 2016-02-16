% DISP [overload base function]

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

function disp (crit)

loose_spacing = strcmp (get (0, 'FormatSpacing'), 'loose');

fprintf ('<%s>\n', stk_sprintf_sizetype (crit));

if loose_spacing
    fprintf ('\n');
end

% Use '--' if the model has not yet been specified
model = get_model (crit);
if isempty (model)
    str_model = '--';
else
    str_model = ['<' stk_sprintf_sizetype(model) '>'];
end

% Use '--' when the threshold value is NaN (i.e., not specified)
tv = crit.threshold_value;
if isnan (tv)
    str_tv = '--';
else
    str_tv = num2str (tv);
end

str_tqo = num2str (crit.threshold_quantile_order);
if ~ strcmp (crit.threshold_mode, 'best quantile')
    str_tqo = [str_tqo ' [unused in current mode]'];
end

fprintf ('    model                    : %s\n', str_model);
fprintf ('    goal                     : ''%s''\n', get_goal (crit));
fprintf ('    threshold_mode           : ''%s''\n', crit.threshold_mode);
fprintf ('    threshold_value          : %s\n', str_tv);
fprintf ('    threshold_quantile_order : %s\n', str_tqo);

if loose_spacing
    fprintf ('\n');
end

end % function
