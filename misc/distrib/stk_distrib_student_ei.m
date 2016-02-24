% STK_DISTRIB_STUDENT_EI computes the Student expected improvement
%
% CALL: EI = stk_distrib_student_ei (Z, NU)
%
%    computes the expected improvement of a Student random variable with NU
%    degrees of freedom above the threshold Z.
%
% CALL: EI = stk_distrib_student_ei (Z, NU, MU, SIGMA)
%
%    computes the expected improvement of a Student random variable with NU
%    degrees of freedom, location parameter MU and scale parameter SIGMA,
%    above the threshold Z.
%
% CALL: EI = stk_distrib_student_ei (Z, NU, MU, SIGMA, MINIMIZE)
%
%    computes the expected improvement of a Student random variable with NU
%    degrees of freedom, location parameter MU and scale parameter SIGMA,
%    below the threshold Z if MINIMIZE is true, above the threshold Z
%    otherwise.
%
% REFERENCES
%
%   [1] R. Benassi, J. Bect and E. Vazquez.  Robust Gaussian process-based
%       global optimization using a fully Bayesian expected improvement
%       criterion.  In: Learning and Intelligent Optimization (LION 5),
%       LNCS 6683, pp. 176-190, Springer, 2011
%
%   [2] B. Williams, T. Santner and W. Notz.  Sequential Design of Computer
%       Experiments to Minimize Integrated Response Functions. Statistica
%       Sinica, 10(4):1133-1152, 2000.
%
% See also stk_distrib_normal_ei

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:  Julien Bect     <julien.bect@centralesupelec.fr>
%              Romain Benassi  <romain.benassi@gmail.com>

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

function ei = stk_distrib_student_ei (z, nu, mu, sigma, minimize)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

nu(nu < 0) = nan;

if nargin > 2,
    delta = bsxfun (@minus, mu, z);
else
    % Default: mu = 0;
    delta = - z;
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
else
    minimize = false;
end

% Reduce to the maximization case
if minimize,
    delta = - delta;
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
b = b0 & b2;
if any (b)
    u = delta(b) ./ sigma(b);  nu = nu(b);
    ei(b) = sigma(b) .* ((nu + u .^ 2) ./ (nu - 1) ...
        .* stk_distrib_student_pdf (u, nu) ...
        + u .* stk_distrib_student_cdf (u, nu));
end

% Compute the EI where nu > 1 and sigma == 0
b = b0 & (~ b2);
ei(b) = max (0, delta(b));

% Correct numerical inaccuracies
ei(ei < 0) = 0;

end % function


%!assert (stk_isequal_tolrel (stk_distrib_student_ei (0, 2), 1 / sqrt (2), eps))

%!test  % Decreasing as a function of z
%! ei = stk_distrib_student_ei (linspace (-10, 10, 200), 3.33);
%! assert (all (diff (ei) < 0))

%!shared M, mu, sigma, ei, nu
%! M = randn (1, 10);
%! mu = randn (5, 1);
%! sigma = 1 + rand (1, 1, 7);
%! nu = 2;
%! ei = stk_distrib_student_ei (M, nu, mu, sigma);

%!assert (isequal (size (ei), [5, 10, 7]))
%!assert (all (ei(:) >= 0))
%!assert (isequal (ei, stk_distrib_student_ei (M, nu, mu, sigma, false)));
%!assert (isequal (ei, stk_distrib_student_ei (-M, nu, -mu, sigma, true)));
