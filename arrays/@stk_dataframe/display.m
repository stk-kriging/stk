% DISPLAY [overload base function]
%
% Example:
%    format short
%    x = [1 1e6 rand; 10 -1e10 rand; 100 1e-22 rand];
%    stk_dataframe(x)  % implicitely calls display()

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function display (x, varargin)

fprintf ('\n%s = <%s>\n', inputname (1), stk_sprintf_sizetype (x));

if strcmp ('basic', stk_options_get ('stk_dataframe', 'disp_format'))
    fprintf ('\n');
end

disp (x, varargin{:});

fprintf ('\n');

end % function


%!test display (stk_dataframe (rand (3, 2)));
