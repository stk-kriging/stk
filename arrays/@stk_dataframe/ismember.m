% ISMEMBER [overload base function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
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

function varargout = ismember (A, B, varargin)

if ~ all (cellfun (@ischar, varargin))
    stk_error ('Invalid flag (should be a string).', 'InvalidArgument');
end

varargout = cell (1, max (nargout, 1));

if isa (A, 'stk_dataframe')
    
    [varargout{:}] = ismember (A.data, B, varargin{:});
    
else  % B is an stk_dataframe object
    
    [varargout{:}] = ismember (A, B.data, varargin{:});
    
end

end % function


%!shared u, x, u1, x1, u2, x2
%! u = rand (10, 4);
%! x = stk_dataframe (u);
%! x1 = x(1, :);
%! u1 = double (x1);
%! u2 = - ones (1, 4);
%! x2 = stk_dataframe (u2);

%!assert (ismember (u1, x, 'rows'))
%!assert (ismember (x1, u, 'rows'))
%!assert (ismember (x1, x, 'rows'))

%!assert (~ ismember (u2, x, 'rows'))
%!assert (~ ismember (x2, u, 'rows'))
%!assert (~ ismember (x2, x, 'rows'))

%!test
%! [b, idx] = ismember ([x2; x1; x1], x, 'rows');
%! assert (isequal (b, [false; true; true]));
%! assert (isequal (idx, [0; 1; 1]))
