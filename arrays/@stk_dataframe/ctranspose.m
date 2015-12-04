% CTRANSPOSE [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function y = ctranspose(x)

rn = get(x, 'rownames');
cn = get(x, 'colnames');

y = stk_dataframe(ctranspose(x.data), rn', cn');

end % function

% note: complex-valued dataframes are supported but, currently,
%       not properly displayed

%!test
%! u = rand(3, 2) + 1i * rand(3, 2);
%! data = stk_dataframe(u, {'x' 'y'}, {'obs1'; 'obs2'; 'obs3'});
%! data = data';
%! assert (isa(data, 'stk_dataframe') && isequal(double(data), u'));
%! assert (isequal(data.rownames, {'x'; 'y'}));
%! assert (isequal(data.colnames, {'obs1' 'obs2' 'obs3'}));
