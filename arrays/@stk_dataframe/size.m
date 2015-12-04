% SIZE [overload base function]

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

function varargout = size(x, varargin)

varargout = cell(1, max(nargout, 1));
[varargout{:}] = size(x.data, varargin{:});

end % function

%!shared x
%! x = stk_dataframe([1 2; 3 4; 5 6]);
%!assert (isequal (size(x), [3 2]))
%!assert (numel(x) == 1)
%!assert (ndims(x) == 2)
%!test size(x); % force exploration of branch nargout == 0

% Note: numel MUST return 1 and not prod(size(x))
% http://www.mathworks.fr/support/solutions/en/data/1-19EZ0/?1-19EZ0

