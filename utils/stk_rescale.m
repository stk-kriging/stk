% STK_RESCALE rescales a dataset from one box to another

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
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
if isstruct(x),
    xx = x.a;
else
    xx = x;
end
[n, d] = size(xx);

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
    zz = (xx - repmat(xmin, n, 1)) ./ repmat(1./delta, n, 1);
else
    zz = xx;
end

% scale to box2 (zz --> yy)
if ~isempty(box2),
    zmin = box2(1, :);
    zmax = box2(2, :);
    delta = zmax - zmin;
    yy = repmat(zmin, n, 1) + zz .* repmat(delta, n, 1);
else
    yy = zz;
end

% output
if isstruct(x),
    y = x;
    y.a = yy;
else
    y = yy;
end

end % function stk_rescale
