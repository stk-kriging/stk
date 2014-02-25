% DISTRIB_NORMAL_CDF ...

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

function [p, q] = distrib_normal_cdf (x, mu, sigma)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 1,
    x = bsxfun (@minus, x, mu);
end

if nargin > 2,
    [x, sigma] = stk_commonsize (x, sigma);
    x = x ./ sigma;
    k0 = (sigma > 0);
else
    k0 = 1;
end
   
p = nan (size (x));
q = nan (size (x));

k0 = k0 & (~ isnan (x));
kp = (x > 0);
kn = k0 & (~ kp);
kp = k0 & kp;

% Deal with positive values of x: compute q first, then p = 1 - q
q(kp) = 0.5 * erfc (0.707106781186547524 * x(kp));
p(kp) = 1 - q(kp);

% Deal with negative values of x: compute p first, then q = 1 - p
p(kn) = 0.5 * erfc (- 0.707106781186547524 * x(kn));
q(kn) = 1 - p(kn);

end % function distrib_normal_cdf


%!assert (stk_isequal_tolrel (distrib_normal_cdf ([1; 3], 1, [1 10]),  ...
%!                 [0.5, ...  % normcdf ((1 - 1) / 1)
%!                  0.5; ...  % normcdf ((1 - 1) / 10)
%!                  0.5 * erfc(-sqrt(2)),    ...  % normcdf ((3 - 1) / 1)
%!                  0.5 * erfc(-0.1*sqrt(2)) ...  % normcdf ((3 - 1) / 10)
%!                 ], eps));

%!test
%! [p, q] = distrib_normal_cdf (10);
%! assert (isequal (p, 1.0));
%! assert (stk_isequal_tolrel (q, 7.6198530241604975e-24, eps));

%!assert (isequal (distrib_normal_cdf ( 0.0), 0.5));
%!assert (isequal (distrib_normal_cdf ( inf), 1.0));
%!assert (isequal (distrib_normal_cdf (-inf), 0.0));
%!assert (isnan   (distrib_normal_cdf ( nan)));
%!assert (isnan   (distrib_normal_cdf (0, 0, -1)));
