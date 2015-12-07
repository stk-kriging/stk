% STK_IS_LHS tests if a given set of points forms a LHS
%
% CALL: OK = stk_is_lhs (X, N, DIM, BOX)
%
%    tests if X is a Latin Hypercube Sample (LHS) of size N, over the hyper-
%    rectangle BOX of dimension DIM. The result OK is true if X is a LHS and
%    false otherwise.
%
% CALL: OK = stk_is_lhs (X, N, DIM)
%
%    tests if X is a Latin Hypercube Sample (LHS) of size N, over the hyper-
%    rectangle [0; 1]^DIM.
%
% CALL: OK = stk_is_lhs (X)
%
%    tests if X is a Latin Hypercube Sample (LHS). Both the size N and the
%    number DIM of factors are inferred from X.
%
% All three calling syntaxes accept both matrix-type inputs or data structures
% (with an 'a' field) for X.

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
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

function b = stk_is_lhs (x, n, dim, box)

if nargin > 4,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

x = double (x);

if nargin == 1,
    [n dim] = size (x);
elseif nargin == 2,
    if size (x, 1) ~= n,
        b = false;  return;
    end
    dim = size (x, 2);
else % nargin > 2
    if ~ isequal (size (x), [n dim])
        b = false;  return;
    end
end

% read argument 'box'
if (nargin < 4) || (isempty (box))
    xmin = zeros (1, dim);
    xmax = ones (1, dim);
else
    if ~ isa (box, 'stk_hrect')
        box = stk_hrect (box);
    end
    xmin = box.lower_bounds;
    xmax = box.upper_bounds;
end

for j = 1:dim,
    
    y = x(:,j);
    
    if (xmin(j) > min(y)) || (xmax(j) < max(y))
        b = false;  return;
    end
    
    y = (y - xmin(j)) / (xmax(j) - xmin(j));
    y = ceil (y * n);
    if ~ isequal (sort (y), (1:n)'),
        b = false;  return;
    end
    
end

b = true;

end % function
