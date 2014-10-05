% STK_RESCALE [overload STK function]

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

function [x, a, b] = stk_rescale(x, varargin)

[x.data, a, b] = stk_rescale(x.data, varargin{:});

end % function stk_rescale

%!test
%! u = rand(5, 1) * 2;
%! x = stk_dataframe(u);
%! y = stk_rescale(x, [0; 2], [0; 3]);
%! assert (isa (y, 'stk_dataframe') && isequal(double(y), u * 3/2))
