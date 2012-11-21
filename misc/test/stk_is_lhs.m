% STK_IS_LHS tests if a given set of points forms a LHS
%
% CALL: OK = stk_is_lhs(X, N, DIM, BOX)
%
%    tests if X is a Latin Hypercube Sample (LHS) of size N, over the hyper-
%    rectangle BOX of dimension DIM. The result OK is true if X is a LHS and
%    false otherwise.
%
% CALL: OK = stk_is_lhs(X, N, DIM)
%
%    tests if X is a Latin Hypercube Sample (LHS) of size N, over the hyper-
%    rectangle [0; 1]^DIM.
%
% CALL: OK = stk_is_lhs(X)
%
%    tests if X is a Latin Hypercube Sample (LHS). Both the size N and the 
%    number DIM of factors are inferred from X.
%
% All three calling syntaxes accepts both matrix-type inputs or data structures
% (with an 'a' field) for X.
  
% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
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

function b = stk_is_lhs(x, n, dim, box)
stk_narginchk(1, 4);

x = stk_datastruct(x);

if nargin == 1,
    [n dim] = size(x.a);
else
    if ~isequal(size(x.a), [n dim])
        errmsg = 'Incorrect dimensions.';
        stk_error(errmsg, 'IncorrectArgument');
    end
end

if nargin < 4,
    box = [zeros(1, dim); ones(1, dim)];
end

xmin = box(1, :);
xmax = box(2, :);

for j = 1:dim,
    
    y = x.a(:,j);
    
    if (xmin(j) > min(y)) || (xmax(j) < max(y))
        b = false; return;
    end
    
    y = (y - xmin(j)) / (xmax(j) - xmin(j));
    y = ceil(y * n);
    if ~isequal(sort(y), (1:n)'),
        b = false; return;
    end
    
end

b = true;

end