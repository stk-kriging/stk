% APPLY maps a function to the rows or columns of a dataframe.

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function z = apply(x, dim, F, u)

if nargin == 4
    uu = {u};
else
    uu = {};
end

switch dim
    case 1 % act along columns
        z = F(x.data, uu{:}, 1);
    case 2, % act along rows (less usual)
        z = F(x.data, uu{:}, 2);
    otherwise
        stk_error('Incorrect dimension specifier', 'IncorrectDimSpec');
end

end % function apply
