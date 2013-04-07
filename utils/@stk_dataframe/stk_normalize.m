% STK_NORMALIZE normalizes a dataset to [0; 1]^DIM.

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

function y = stk_normalize(x, varargin)

ydata = stk_normalize(x.data, varargin{:});

y = stk_dataframe(ydata, x.vnames);

end % function stk_normalize

%!test
%! u = rand(6, 2) * 2;
%! x = stk_dataframe(u);
%! y = stk_normalize(x);
%! assert (isa (y, 'stk_dataframe') && isequal(double(y), stk_normalize(u)))
