% STK_RESCALE [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
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

function [x, a, b] = stk_rescale (x, varargin)

if (~ isa (x, 'stk_factorialdesign'))
    % One of the box arguments is an stk_factorialdesign object
    stk_error (['stk_factorialdesign objects cannot be used as values '
        'for ''box'' arguments.'], 'TypeMismatch');
end

% Rescale using @stk_dataframe/stk_rescale
[x.stk_dataframe, a, b] = stk_rescale (x.stk_dataframe, varargin{:});

% Apply the same normalization to levels
for j = 1:(length (x.levels))
    x.levels{j} = a(j) + b(j) * x.levels{j};
end

end % function

%!test
%! x = stk_factorialdesign ({[1 2], [5 6]});
%! y = stk_factorialdesign ({[0 3], [0 3]});
%! z = stk_rescale (x, [1 5; 2 6], [0 0; 3 3]);
%! assert (stk_isequal_tolabs (y, z))
