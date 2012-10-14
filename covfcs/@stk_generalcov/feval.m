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

function K = feval(cov, x, y, diff)
stk_narginchk(2, 4);

% extract data matrices from structures, if appropriate
if isstruct(x), x = x.a; end
if (nargin > 2) && isstruct(y), y = y.a; end

% no special case for cov(x, x)
if (nargin < 3) || isempty(y),
    y = x;
end

% default: compute the value (not a derivative)
if nargin < 4,
    diff = -1;
end

K = feval(cov.fun, cov.param, x, y, diff);

end % function feval

