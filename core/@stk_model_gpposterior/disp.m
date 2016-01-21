% DISP [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function disp (model)

loose_spacing = strcmp (get (0, 'FormatSpacing'), 'loose');

fprintf ('<%s>\n', stk_sprintf_sizetype (model));

if loose_spacing
    fprintf ('\n');
end

if ~ isscalar (model)
    return
end

if isempty (model.prior_model)
    str_prior_model = '--';
else
    str_prior_model = ['<' stk_sprintf_sizetype(model.prior_model) '>'];
end

if size (model.input_data, 1) == 0
    str_input_data = '--';
else
    str_input_data = ['<' stk_sprintf_sizetype(model.input_data) '>'];
end

if size (model.output_data, 1) == 0
    str_output_data = '--';
else
    str_output_data = ['<' stk_sprintf_sizetype(model.input_data) '>'];
end

fprintf ('         prior_model: %s\n', str_prior_model);
fprintf ('           input_dim: %d\n', get_input_dim (model));
fprintf ('          input_data: %s\n', str_input_data);
fprintf ('          output_dim: %d\n', 1);
fprintf ('         output_data: %s\n', str_output_data);
fprintf ('               param: <%s>\n', ...
    stk_sprintf_sizetype (model.prior_model.param));

fprintf ('    lognoisevariance: ');
lnv = model.prior_model.lognoisevariance;
if isscalar (lnv)
    fprintf ('%s\n', num2str (lnv));
else
    fprintf ('<%s>\n', stk_sprintf_sizetype (lnv));
end

if loose_spacing
    fprintf ('\n');
end

end % function
