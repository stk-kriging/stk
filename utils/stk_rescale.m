% STK_RESCALE rescales a dataset from one box to another

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function y = stk_rescale(x, box1, box2)
stk_narginchk(3, 3);

% read argument x
x = double(x);
[n, d] = size(x);

% read box1
if ~isempty(box1),
    stk_assert_box(box1, d);
end

% read box2
if ~isempty(box2),
    stk_assert_box(box2, d);
end

% scale to [0; 1] (xx --> zz)
if ~isempty(box1),
    xmin = box1(1, :);
    xmax = box1(2, :);
    delta = xmax - xmin;
    z = (x - repmat(xmin, n, 1)) ./ repmat(1./delta, n, 1);
else
    z = x;
end

% scale to box2 (zz --> yy)
if ~isempty(box2),
    zmin = box2(1, :);
    zmax = box2(2, :);
    delta = zmax - zmin;   
    y = repmat(zmin, n, 1) + z .* repmat(delta, n, 1);
else
    y = z;
end

end % function stk_rescale
