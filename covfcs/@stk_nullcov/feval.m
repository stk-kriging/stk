% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

function k = feval(cov, x, y, diff) %#ok<INUSL>
stk_narginchk(2, 4);

% x
if isstruct(x), x = x.a; end
nx = size(x, 1);

% y
if (nargin > 2)
    if isstruct(y), y = y.a; end
    ny = size(y, 1);
else
    % special case y = x
    y = [];
    ny = nx;
end

% check diff argument
if (nargin == 4) && (diff ~= -1)
    errmsg = 'diff can only be equal to -1 for stk_nullcov objects.';
    stk_error(errmsg, 'IncorrectArgument');
end

k = sparse(nx, ny);

end % function feval
