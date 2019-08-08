% FEVAL [overload base function]

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function v = stk_variance_eval (gn, x, diff)

% Defaut value for 'diff' (arg #3): -1
if nargin < 3,  diff = -1;  end

switch diff
    case {-1, 1}
        % -1 means "no derivative"
        % +1 means "derivative wrt log_dispersion"
        v = exp (gn.log_dispersion) * feval (gn.variance_function, double (x));
    otherwise
        stk_error ('diff should be either -1 or +1', 'IncorrectArgument');
end

end % function
