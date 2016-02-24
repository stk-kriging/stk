% NDGRID produces ndgrid-style coordinate arrays
%
% CALL: [X1, X2, ...] = ndgrid (X)
%
%    produces ndgrid-style coordinate arrays X1, X2, ... Xd based on the
%    @stk_factorialdesign object X (where d is the number of columns of
%    X). This is equivalent to
%
%       [X1, ..., Xd] = ndgrid (X.levels{1}, ..., X.levels{d});
%
% See also: ndgrid

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function varargout = ndgrid (x)

d = length (x.levels);

if nargout > d
    
    stk_error ('Too many output arguments.', 'TooManyOutputArgs');
    
else
    
    if (d == 0) || any (cellfun (@isempty, x.levels))
        
        varargout = repmat ({[]}, 1, nargout);
        
    elseif d == 1
        
        varargout = {x.levels{1}(:)};
        
    else
        
        varargout = cell (1, max (nargout, 1));
        [varargout{:}] = ndgrid (x.levels{:});
        
    end
    
end

end % function


%--- general case -------------------------------------------------------------

%!shared data
%! data = stk_factorialdesign ({[0 1], [5 6 7]});

%!test % nargout = 0
%! ndgrid (data);
%! assert (isequal (ans, [0 0 0; 1 1 1]));

%!test % nargout = 1
%! x = ndgrid (data);
%! assert (isequal (x, [0 0 0; 1 1 1]));

%!test % nargout = 2
%! [x, y] = ndgrid (data);
%! assert (isequal ({x, y}, {[0 0 0; 1 1 1], [5 6 7; 5 6 7]}));

%!error % nargout = 3
%! [x, y, z] = ndgrid (data);

%--- special cases ------------------------------------------------------------

%!test
%! data = stk_factorialdesign ({[], []});
%! [x, y] = ndgrid (data);
%! assert (isequal ({x, y}, {[], []}));

%!test
%! data = stk_factorialdesign ({[1:3]});
%! x = ndgrid (data);
%! assert (isequal (x, [1; 2; 3]));
