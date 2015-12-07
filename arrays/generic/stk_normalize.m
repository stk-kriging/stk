% STK_NORMALIZE normalizes a dataset to [0; 1] ^ DIM

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

function [x, a, b] = stk_normalize (x, box, varargin)

if nargin < 2,
    box = [];
end

% Ensure that box is an stk_hrect object
if ~ isa (box, 'stk_hrect')
    if isempty (box),
        box = stk_boundingbox (x);
    else
        box = stk_hrect (box);
    end
end

% Call @stk_hrect/stk_normalize
[x, a, b] = stk_normalize (x, box, varargin{:});

end % function


%!shared x, box, y1, y2, y3, y4
%! n = 5;  box = [2; 3];  x = box(1) + diff (box) * rand (n, 1);

%!error  y1 = stk_normalize ();
%!test   y2 = stk_normalize (x);
%!test   y3 = stk_normalize (x, box);
%!error  y4 = stk_normalize (x, box, log (2));

%!test assert (~ any ((y2 < -10 * eps) | (y2 > 1 + 10 * eps)));
%!test assert (~ any ((y3 < -10 * eps) | (y3 > 1 + 10 * eps)));
