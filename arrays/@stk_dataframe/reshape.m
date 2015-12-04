% RESHAPE [overload base function]
%
% Note : the result of reshaping a dataframe is again a dataframe, but all row
% and columns names are lost in the process.

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

function y = reshape (x, varargin)

% Silently assume that x is a dataframe
% (this can go wrong if a dataframe is hidden in varargin, but hey...)

y = stk_dataframe (reshape (x.data, varargin{:}));

end % function


%!test
%! x = stk_dataframe (randn (10, 3));
%! y = reshape (x, 5, 6);
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [5 6]))
