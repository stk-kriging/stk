% STK_IS_LHS tests if a given set of points forms a LHS

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
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