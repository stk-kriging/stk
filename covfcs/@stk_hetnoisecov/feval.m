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

% extract data matrices, if appropriate
if isstruct(x), x = x.a; end
if (nargin > 2) && isstruct(y), y = y.a; end

% only cov(x, x) is supported for this class of covariance objects !
if (nargin > 2) && ~isequal(x, y)
    stk_error('cov(x, y) is not implemented yet.', 'NotImplementedYet');
end
        
% default: compute the value (not a derivative)
if (nargin > 3) && (diff ~= -1),
    stk_error('Incorrect vaue for the diff parameter.', 'IncorrectArgument');
end

nx = size(x, 1);

if ~isempty(cov.prop.varfun),
    % in this case we have a function that gives the value of the variance at any point
    v = feval(cov.prop.varfun, x);
    K = spdiags(v(:), 0, nx, nx);
else
    % otherwise cov.variance is a vector of variances corresponding to the locations cov.x
    if isequal(cov.prop.x, x),
        K = spdiags(cov.prop.v(:), 0, nx, nx);
    else
        stk_error('Improper use of this kind of covariance object.', 'IncorrectArgument');
    end
end

end % function feval
