% STK_SPRINTF_COLVECT_FIXEDPOINT ...

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

function [str, err] = stk_sprintf_colvect_fixedpoint(x, max_width)

if nargin < 2,
    max_width = 10;
end

% turn x into a column vector
x = double(x);
x = x(:);

% get rid of negative zeros
b = (x == 0);
x(b) = +0.0;

% Is there any negative element ?
any_negative = any(x < 0);

% Start without decimal part
ax = abs(x);
n1 = max(1, floor(log10(max(ax))) + 1);
n2 = 0;
n3 = any_negative;

% Abort this is already too long
if (n1 + n2 + n3) > max_width
    str = repmat('#', length(x), max_width);
    err = +inf;
    return;
end

% Otherwise, this is our current best solution
best_err = max(abs(fix(x) - x));
best_n2  = 0;

% Should we add a decimal part ?
if (best_err > eps) && ((n1 + n2 + n3 + 2) <= max_width)
    % We can add a decimal part, so let's do it...
    while (best_err > eps) && ((n1 + n2 + n3) < max_width)
        n2  = n2 + 1; % add one decimal
        n3  = 1 + any_negative; % +1 for the comma
        c   = 10^(-n2);
        xx  = floor(ax / c) * c;
        err = max(ax - xx);
        if err < best_err - 0.5*c,
            best_err = err;
            best_n2  = n2;
        end
    end
end
err = best_err;
n2  = best_n2;

fmt = sprintf('%%%d.%df', n1 + n2 + n3, n2);
str = arrayfun(@(u)(sprintf(fmt, u)), x, 'UniformOutput', false);
str = char(str{:});

end % function stk_sprintf_colvect_fixedpoint

%!shared x s
%! x = [1.2; 3.48];
%!test s = stk_sprintf_colvect_fixedpoint(x, 1);
%!assert (isequal(s, ['1'; '3']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 2);
%!assert (isequal(s, ['1'; '3']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 3);
%!assert (isequal(s, ['1.2'; '3.5']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 4);
%!assert (isequal(s, ['1.20'; '3.48']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 5);
%!assert (isequal(s, ['1.20'; '3.48']))

%!shared x s
%! x = [1.2; -3.48];
%!test s = stk_sprintf_colvect_fixedpoint(x, 1);
%!assert (isequal(s, ['#'; '#']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 2);
%!assert (isequal(s, [' 1'; '-3']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 3);
%!assert (isequal(s, [' 1'; '-3']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 4);
%!assert (isequal(s, [' 1.2'; '-3.5']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 5);
%!assert (isequal(s, [' 1.20'; '-3.48']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 6);
%!assert (isequal(s, [' 1.20'; '-3.48']))

%!shared x s
%! x = [0.2; 0.48];
%!test s = stk_sprintf_colvect_fixedpoint(x, 1);
%!assert (isequal(s, ['0'; '0']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 2);
%!assert (isequal(s, ['0'; '0']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 3);
%!assert (isequal(s, ['0.2'; '0.5']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 4);
%!assert (isequal(s, ['0.20'; '0.48']))
%!test s = stk_sprintf_colvect_fixedpoint(x, 5);
%!assert (isequal(s, ['0.20'; '0.48']))
