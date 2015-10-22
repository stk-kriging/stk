% ISMEMBER [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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
else
    % At least of of the arguments (A or B) is an stk_hrect,
    % therefore ismember should work on rows
    flags = unique ([{'rows'} varargin{:}]);
end

varargout = cell (1, max (nargout, 1));

% If A is an stk_hrect, treat it as any other stk_dataframe would be treated
if isa (A, 'stk_hrect'),  A = A.stk_dataframe;  end

if isa (B, 'stk_hrect'),
    % If B is an stk_hrect, ismember tests whether A (or the points in A)
    % belong to the hyper-rectangle B
    if nargout > 1,
        stk_error (['Cannot return member indices when testing for ' ...
            'membership to an hyper-rectangle.'], 'TooManyOutputArgs');
    end
    A = double (A);
    b1 = bsxfun (@ge, A, B.stk_dataframe.data(1, :));
    b2 = bsxfun (@le, A, B.stk_dataframe.data(2, :));    
    varargout{1} = all (b1 & b2, 2);
else
    % Otherwise, use @stk_dataframe/ismember
    [varargout{:}] = ismember (A, B.stk_dataframe, flags{:});
end

end % function ismember

%!shared n, box
%! n = 5;
%! box = stk_hrect (n);

%!assert (ismember (box(1, :), box))
%!assert (ismember (box(2, :), box))
%!assert (ismember (.5 * ones (1, 5), box))
%!assert (~ ismember (box(1, :) - 1, box))
%!assert (~ ismember (box(2, :) + 1, box))

%!test
%! y = double (box);  y = [y; y + 2];
%! assert (isequal (ismember (y, box), [1; 1; 0; 0]))
