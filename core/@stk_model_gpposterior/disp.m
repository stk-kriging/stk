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

fprintf ('         prior_model: <%s>\n', ...
    stk_sprintf_sizetype (model.prior_model));
fprintf ('          input_data: <%s>\n', ...
    stk_sprintf_sizetype (model.input_data));
fprintf ('         output_data: <%s>\n', ...
    stk_sprintf_sizetype (model.output_data));

fprintf ('                 dim: %d\n', model.dim);
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
