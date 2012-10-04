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

function k = stk_nullcov(param, x, y, diff)

stk_narginchk(3, 4);

if ~isempty(param),
    stk_error('Incorrect parameter vector (should be empty).', 'IncorrectArgument');
end

if (nargin == 4) && (diff ~= -1)    
    stk_error('Sorry, I have no derivative to provide...', 'IncorrectArgument');
end

if isstruct(x), x = x.a; end
if isstruct(y), y = y.a; end

k = sparse(size(x, 1), size(y, 1));

end % function stk_nullcov