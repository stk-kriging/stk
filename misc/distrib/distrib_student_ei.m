% DISTRIB_STUDENT_EI ...

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

function ei = distrib_student_ei (x, nu, mu, sigma, minimize)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

nu(nu < 0) = nan;

if nargin > 2,
    delta = bsxfun (@minus, mu, x);
else
    % Default: mu = 0;
    delta = - x;
end

if nargin > 3,
    sigma(sigma < 0) = nan;
else
    % Default
    sigma = 1;
end

% Default: compute the EI for a maximization problem
if nargin > 4,    
    minimize = logical (minimize);
    if ~ minimize,
        delta = - delta;
    end
end

[delta, nu, sigma] = stk_commonsize (delta, nu, sigma);

ei = nan (size (delta));

b0 = ~ (isnan (delta) | isnan (nu) | isnan (sigma));
b1 = (nu > 1);   
b2 = (sigma > 0);

% The EI is infinite for nu <= 1
ei(b0 & (~ b1)) = +inf;
b0 = b0 & b1;

% Compute the EI where nu > 1 and sigma > 0
b = b0 & b2;  u = delta(b) ./ sigma(b);  nu = nu(b);
ei(b) = sigma(b) .* ((nu + u .^ 2) ./ (nu - 1) ...
    .* distrib_student_pdf (u, nu) + u .* distrib_student_cdf (u, nu));

% Compute the EI where nu > 1 and sigma == 0
b = b0 & (~ b2);
ei(b) = max (0, delta(b));

% Correct numerical inaccuracies
ei(ei < 0) = 0;

end % function distrib_student_ei


%!assert (stk_isequal_tolrel (distrib_student_ei (0, 2), 1 / sqrt (2), eps))

%!test % decreasing as a function of x
%! ei = distrib_student_ei (linspace (-10, 10, 200), 3.33);
%! assert (all (diff (ei) < 0))

%!test % size and positivity of the result
%! M = randn (1, 10);
%! mu = randn (5, 1);
%! sigma = 1 + rand (1, 1, 7);
%! ei = distrib_normal_ei (M, mu, sigma);
%! assert (isequal (size (ei), [5, 10, 7]))
%! assert (all (ei(:) >= 0))