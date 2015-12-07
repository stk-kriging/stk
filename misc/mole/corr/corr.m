% CORR ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@centralesupelec.fr>
%
%    This code is looesely based on Octave 3.7.7+'s quantile.m., where
%    the original copyright notice was:
%
%       ## Copyright (C) 1996-2013 John W. Eaton
%       ##
%       ## This file is part of Octave.
%       ##
%       ## Octave is free software; you can redistribute it and/or modify it
%       ## under the terms of the GNU General Public License as published by
%       ## the Free Software Foundation; either version 3 of the License, or
%       ## (at your option) any later version.
%       ##
%       ## Octave is distributed in the hope that it will be useful, but
%       ## WITHOUT ANY WARRANTY; without even the implied warranty of
%       ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%       ## General Public License for more details.
%       ##
%       ## You should have received a copy of the GNU General Public License
%       ## along with Octave; see the file COPYING.  If not, see
%       ## <http://www.gnu.org/licenses/>.

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

function c = corr (x, y)

% Note: the original Octave code has been rewritten to avoid calling cov, since
% there is a long-standing incompatiblity between Matlab's cov and Octave's cov
% (see https://savannah.gnu.org/bugs/?40751)

n = size (x, 1);

x = x - repmat (mean (x), n, 1);
sx = std (x, 1);
sx (sx == 0) = nan;

if nargin < 2,
    y = x;
    sy = sx;
else
    assert (size (y, 1) == n);
    y = y - repmat (mean (y), n, 1);
    sy = std (y, 1)
    sy (sy == 0) = nan;
end

% Special case, scalar is always 100% correlated with itself
if isscalar (x)
    if isa (x, 'single') && isa (y, 'single')
        c = single (1.0);
    else
        c = 1.0;
    end
    return;
end

c = x' * y;
s = sx' * sy;
c = c ./ (n * s);

end % function


%!test
%! x = rand (10);
%! cc1 = corr (x);
%! cc2 = corr (x, x);
%! assert (isequal (size (cc1), [10, 10]))
%! assert (isequal (size (cc2), [10, 10]))
%! assert (stk_isequal_tolabs (cc1, cc2, sqrt (eps)))

%!test
%! x = [1:3]';
%! y = [3:-1:1]';
%! assert (stk_isequal_tolabs (corr (x, y), -1, 5*eps));
%! assert (stk_isequal_tolabs (corr (x, flipud (y)), 1, 5*eps));
%! assert (stk_isequal_tolabs (corr ([x, y]), [1 -1; -1 1], 5*eps));

%!test
%! x = single ([1:3]');
%! y = single ([3:-1:1]');
%! assert (stk_isequal_tolabs (corr (x, y), single (-1), 5*eps));
%! assert (stk_isequal_tolabs (corr (x, flipud (y)), single (1), 5*eps));
%! assert (stk_isequal_tolabs (corr ([x, y]), single ([1 -1; -1 1]), 5*eps));

%!assert (stk_isequal_tolabs (corr (5), 1))
%!assert (stk_isequal_tolabs (corr (single (5)), single (1)))

%% Test input validation
%!error corr ()
%!error corr (1, 2, 3)
%!error corr ([1; 2], ["A", "B"])
%!error corr (ones (2,2,2))
%!error corr (ones (2,2), ones (2,2,2))

