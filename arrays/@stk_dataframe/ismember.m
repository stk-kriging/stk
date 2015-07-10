% ISMEMBER [overload base function]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function varargout = ismember (A, B, varargin)

if ~ all (cellfun (@ischar, varargin))
    stk_error ('Invalid flag (should be a string).', 'InvalidArgument');
else
    % At least of of the arguments (A or B) is an stk_dataframe,
    % therefore ismember should work on rows
    flags = unique ([{'rows'} varargin{:}]);
end

varargout = cell (1, max (nargout, 1));

if isa (A, 'stk_dataframe'),  A = A.data;  end
if isa (B, 'stk_dataframe'),  B = B.data;  end

[varargout{:}] = ismember (A, B, flags{:});

end % function ismember


%!shared u, x, u1, x1, u2, x2
%! u = rand (10, 4);
%! x = stk_dataframe (u);
%! x1 = x(1, :);
%! u1 = double (x1);
%! u2 = - ones (1, 4);
%! x2 = stk_dataframe (u2);

%!assert (ismember (u1, x))
%!assert (ismember (x1, u))
%!assert (ismember (x1, x))

%!assert (~ ismember (u2, x))
%!assert (~ ismember (x2, u))
%!assert (~ ismember (x2, x))

%!test
%! [b, idx] = ismember ([x2; x1; x1], x);
%! assert (isequal (b, [false; true; true]));
%! assert (isequal (idx, [0; 1; 1]))
