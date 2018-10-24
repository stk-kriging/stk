% DISP [overload base function]
%
% EXPERIMENTAL CLASS WARNING:  The stk_model_gn_heteroscedastic0 class is
%    currently considered experimental.  STK users who wish to experiment with
%    it are welcome to do so, but should be aware that API-breaking changes
%    are likely to happen in future releases.  We invite them to direct any
%    questions, remarks or comments about this experimental class to the STK
%    mailing list.

% Copyright Notice
%
%    Copyright (C) 2015-2018 CentraleSupelec
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

function disp (gn)

loose_spacing = stk_disp_isloose ();

fprintf ('<%s>\n', stk_sprintf_sizetype (gn));

if loose_spacing
    fprintf ('|\n');
end

if isa (gn.variance_function, 'function_handle')
    variance_function = func2str (gn.variance_function);
else
    variance_function = gn.variance_function;
end

fprintf ('|  Heteroscedastic variance model:  tau^2(x) = dispersion * variance_function(x)\n');

if loose_spacing
    fprintf ('|\n');
end

fprintf ('|           dispersion: %s', num2str (exp (gn.log_dispersion)));
fprintf ('   [log_dispersion = %s]\n', num2str (gn.log_dispersion));
fprintf ('|    variance_function: %s\n', variance_function);

if loose_spacing
    fprintf ('|\n');
end

end % function
