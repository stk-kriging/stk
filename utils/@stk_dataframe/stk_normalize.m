% STK_NORMALIZE [overloaded STK function]

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

function [x, a, b] = stk_normalize(x, varargin)

[x.data, a, b] = stk_normalize(x.data, varargin{:});

end % function stk_normalize

%!test
%! u = rand (6, 2) * 2;
%! x = stk_dataframe (u);
%! y = stk_normalize (x);
%! assert (isa (y, 'stk_dataframe') ...
%!    && stk_isequal_tolabs (double (y), stk_normalize (u)))
