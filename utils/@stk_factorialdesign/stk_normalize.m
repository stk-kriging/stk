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

function x = stk_normalize(x, varargin)

[x.stk_dataframe, a, b] = stk_normalize(x.stk_dataframe, varargin{:});

for j = 1:length(x.levels)    
    x.levels{j} = a(j) + b(j) * x.levels{j};
end

end % function stk_normalize

%!test
%! x = stk_factorialdesign({[1 2], [5 6]})
%! y = stk_factorialdesign({[0 1], [0 1]})
%! assert(isequal(stk_normalize(x), y))
