% QUANTILE [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@centralesupelec.fr>

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

function z = quantile (x, p, dim)

if nargin < 3,
    dim = 1;
end

z = apply (x, dim, @quantile, p);

end % function

%!shared x1, df1, p
%! x1 = rand (9, 3);
%! df1 = stk_dataframe (x1, {'a', 'b', 'c'});
%! p = 0.95;
%!assert (isequal (quantile (df1, p),    quantile (x1, p)))
%!assert (isequal (quantile (df1, p, 1), quantile (x1, p)))
%!assert (isequal (quantile (df1, p, 2), quantile (x1, p, 2)))
