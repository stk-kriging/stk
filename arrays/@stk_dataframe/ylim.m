% YLIM [overload base function]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function varargout = ylim (arg1, arg2)

varargout = cell (1, nargout);

if nargin == 1,
    [varargout{:}] = ylim (double (arg1));
    return
end

if isa (arg1, 'stk_dataframe'),  arg1 = double (arg1);  end
if isa (arg2, 'stk_dataframe'),  arg2 = double (arg2);  end

[varargout{:}] = ylim (arg1, arg2);

end % function
