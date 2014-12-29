% STK_BOUNDINGBOX constructs the bounding box for a set of points

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function box = stk_boundingbox (x)

if nargin > 1,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

x_data = double (x);
if (~ ismatrix (x_data))
    stk_error (['Arrays with more than two dimensions are not ' ...
        'supported.'], 'IncorrectSize');
end

xmin = min (x, [], 1);
xmax = max (x, [], 1);
box_data = [xmin; xmax];

box = stk_hrect (box_data);

if isa (x, 'stk_dataframe')
    box.colnames = x.colnames;
end

end % function stk_boundingbox
