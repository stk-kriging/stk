% FEVAL [overload base function]

% Copyright Notice
%
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

function z = feval (lm, x) %#ok<INUSL>

x = double (x);

[n, d] = size (x);

% Use stk_lm_quadratic to compute the quadratic part
z2 = feval (stk_lm_quadratic, x);

% And now compute all monomials of degree exactly 3
z3 = zeros (n, d * (2 + d * (3 + d)) / 6);

c = 1;
for i = 1:d
    u = x(:, i);
    for j = i:d
        v = u .* x(:, j);
        for k = j:d
            z3(:, c) = v .* x(:, k);
            c = c + 1;
        end
    end
end

z = horzcat (z2, z3);

end % function


%!test
%! n = 15; d = 4;
%! x = stk_sampling_randunif (n, d);
%! P = feval (stk_lm_cubic (), x);
%! assert (isequal (size (P), [n, 1 + d * (11 + d * (6 + d)) / 6]))
