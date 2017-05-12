% STK_DISTRIB_NORMAL_EI computes the normal (Gaussian) expected improvement
%
% CALL: EI = stk_distrib_normal_ei (Z)
%
%    computes the expected improvement of a standard normal (Gaussian)
%    random variable above the threshold Z.
%
% CALL: EI = stk_distrib_normal_ei (Z, MU, SIGMA)
%
%    computes the expected improvement of a Gaussian random variable
%    with mean MU and standard deviation SIGMA, above the threshold Z.
%
% CALL: EI = stk_distrib_normal_ei (Z, MU, SIGMA, MINIMIZE)
%
%    computes the expected improvement of a Gaussian random variable
%    with mean MU and standard deviation SIGMA, below the threshold Z
%    if MINIMIZE is true, above the threshold Z otherwise.
%
% NOTE
%
%    Starting with STK 2.4.1, it is recommended to use stk_sampcrit_ei_eval
%    instead of this function.  Be careful, however, with the "direction" of
%    the improvement that you want to compute:
%
%       EI = stk_sampcrit_ei_eval (MU, SIGMA, Z)
%
%    computes the expected improvement *below* the threshold Z, and is thus
%    equivalent to
%
%       EI = stk_distrib_normal_ei (Z, MU, SIGMA, true)
%
%    To compute the expected improvement *above* Z, change signs as follows:
%
%       EI = stk_sampcrit_ei_eval (-MU, SIGMA, -Z)
%
% REFERENCES
%
%   [1] D. R. Jones, M. Schonlau and William J. Welch. Efficient global
%       optimization of expensive black-box functions.  Journal of Global
%       Optimization, 13(4):455-492, 1998.
%
%   [2] J. Mockus, V. Tiesis and A. Zilinskas. The application of Bayesian
%       methods for seeking the extremum. In L.C.W. Dixon and G.P. Szego,
%       editors, Towards Global Optimization, volume 2, pages 117-129, North
%       Holland, New York, 1978.
%
% See also stk_sampcrit_ei_eval, stk_distrib_student_ei

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function ei = stk_distrib_normal_ei (z, mu, sigma, minimize)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 1,
    delta = bsxfun (@minus, mu, z);
else
    % Default: mu = 0;
    delta = - z;
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
else
    minimize = false;
end

% Reduce to the maximization case
if minimize,
    delta = - delta;
end

[delta, sigma] = stk_commonsize (delta, sigma);

ei = nan (size (delta));

b0 = ~ (isnan (delta) | isnan (sigma));
b1 = (sigma > 0);

% Compute the EI where sigma > 0
b = b0 & b1;
if any (b)
    u = delta(b) ./ sigma(b);
    ei(b) = sigma(b) .* (stk_distrib_normal_pdf (u) ...
        + u .* stk_distrib_normal_cdf (u));
end

% Compute the EI where sigma == 0
b = b0 & (~ b1);
ei(b) = max (0, delta(b));

% Correct numerical inaccuracies
ei(ei < 0) = 0;

end % function


%!assert (stk_isequal_tolrel (stk_distrib_normal_ei (0.0), 1 / sqrt (2 * pi), eps))

%!test  % Decreasing as a function of z
%! ei = stk_distrib_normal_ei (linspace (-10, 10, 200));
%! assert (all (diff (ei) < 0))

%!shared M, mu, sigma, ei
%! M = randn (1, 10);
%! mu = randn (5, 1);
%! sigma = 1 + rand (1, 1, 7);
%! ei = stk_distrib_normal_ei (M, mu, sigma);

%!assert (isequal (size (ei), [5, 10, 7]))
%!assert (all (ei(:) >= 0))
%!assert (isequal (ei, stk_distrib_normal_ei (M, mu, sigma, false)));
%!assert (isequal (ei, stk_distrib_normal_ei (-M, -mu, sigma, true)));
