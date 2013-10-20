% DISTRIB_NORMAL_EI ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Authors:   Julien Bect     <julien.bect@supelec.fr>
%               Romain Benassi  <romain.benassi@gmail.com>

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

function ei = distrib_normal_ei (x, mu, sigma, minimize)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 1,
    delta = bsxfun (@minus, mu, x);
else
    % Default: mu = 0;
    delta = - x;
end

if nargin > 2,
    sigma(sigma < 0) = nan;
else
    % Default: sigma = 1
    sigma = 1;
end

% Default: compute the EI for a maximization problem
if nargin > 3,
    minimize = logical (minimize);
    if ~ minimize,
        delta = - delta;
    end
end

[delta, sigma] = commonsize (delta, sigma);

ei = nan (size (delta));

b0 = ~ (isnan (delta) | isnan (sigma));
b1 = (sigma > 0);

% Compute the EI where sigma > 0
b = b0 & b1;
u = delta(b) ./ sigma(b);
ei(b) = sigma(b) .* (distrib_normal_pdf (u) + u .* distrib_normal_cdf (u));

% Compute the EI where sigma == 0
b = b0 & (~ b1);
ei(b) = max (0, delta(b));

% Correct numerical inaccuracies
ei(ei < 0) = 0;

end % function distrib_normal_ei


%!assert (stk_isequal_tolrel (distrib_normal_ei (0.0), 1 / sqrt (2 * pi), eps))

%!test % decreasing as a function of x
%! ei = distrib_normal_ei (linspace (-10, 10, 200));
%! assert (all (diff (ei) < 0))

%!test % size and positivity of the result
%! M = randn (1, 10);
%! mu = randn (5, 1);
%! sigma = 1 + rand (1, 1, 7);
%! ei = distrib_normal_ei (M, mu, sigma);
%! assert (isequal (size (ei), [5, 10, 7]))
%! assert (all (ei(:) >= 0))
