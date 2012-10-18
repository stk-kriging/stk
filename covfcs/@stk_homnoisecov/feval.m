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

% x
if isstruct(x), x = x.a; end
nx = size(x, 1);

% y
if nargin > 2
    if isstruct(y), y = y.a; end
    % only cov(x, x) is supported for this class of covariance objects !
    if ~isempty(y) && ~isequal(x, y)
        stk_error('cov(x, y) is not implemented yet.', 'NotImplementedYet');
    end
end
        
% default: compute the value (not a derivative)
if nargin < 4,
    diff = -1;
end

switch diff,
    
    case {-1, 1}, % value or derivative wrt logvariance
        K = cov.prop.variance * speye(nx, nx);

    otherwise
        stk_error('Incorrect diff argument.', 'IncorrectArgument');

end % switch diff

end % function feval
