% STK_GET_COLNAMES returns the column names of a dataframe

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function colnames = stk_get_colnames(x)

colnames = x.vnames;

end % function stk_get_colnames


%!test
%! x = stk_dataframe(rand(3, 2));
%! assert(isequal(stk_get_colnames(x), {}));

%!test
%! x = stk_dataframe(rand(3, 2), {'u' 'v'});
%! assert(isequal(stk_get_colnames(x), {'u' 'v'}));
