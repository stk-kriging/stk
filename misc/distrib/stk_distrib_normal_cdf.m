% STK_DISTRIB_NORMAL_CDF  [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function [p, q] = stk_distrib_normal_cdf (z, mu, sigma)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 1,
    z = bsxfun (@minus, z, mu);
end

if nargin < 3,
    sigma = 1;
end

if isscalar (sigma)
    if sigma > 0
        z = z / sigma;
        k0 = false;
        k1 = true;
    elseif sigma == 0
        k0 = true;
        k1 = false;
    else
        k0 = false;
        k1 = false;
    end
else
    if ~ isequal (size (z), size (sigma))
        [z, sigma] = stk_commonsize (z, sigma);
    end
    k0 = (sigma == 0);
    k1 = (sigma > 0);
    z(k1) = z(k1) ./ sigma(k1);
end

p = nan (size (z));
q = nan (size (z));

kp = (z >= 0);
kz = ~ isnan (z);

if any (k1)  % sigma > 0
    
    k1 = bsxfun (@and, k1, kz);
    k1n = k1 & (~ kp);
    k1p = k1 & kp;
    
    % Deal with positive values of x: compute q first, then p = 1 - q
    q_k1p = 0.5 * erfc (0.707106781186547524 * z(k1p));
    q(k1p) = q_k1p;
    p(k1p) = 1 - q_k1p;
    
    % Deal with negative values of x: compute p first, then q = 1 - p
    p_k1n = 0.5 * erfc (- 0.707106781186547524 * z(k1n));
    p(k1n) = p_k1n;
    q(k1n) = 1 - p_k1n;
    
end

if any (k0)  % sigma == 0
    
    k0 = bsxfun (@and, k0, kz);
    
    p_k0 = double (kp(k0));
    p(k0) = p_k0;
    q(k0) = 1 - p_k0;
    
end

end % function


%!assert (stk_isequal_tolrel (stk_distrib_normal_cdf ([1; 3], 1, [1 10]),  ...
%!                 [0.5, ...  % normcdf ((1 - 1) / 1)
%!                  0.5; ...  % normcdf ((1 - 1) / 10)
%!                  0.5 * erfc(-sqrt(2)),    ...  % normcdf ((3 - 1) / 1)
%!                  0.5 * erfc(-0.1*sqrt(2)) ...  % normcdf ((3 - 1) / 10)
%!                 ], eps));

%!test
%! [p, q] = stk_distrib_normal_cdf (10);
%! assert (isequal (p, 1.0));
%! assert (stk_isequal_tolrel (q, 7.6198530241604975e-24, eps));

%!assert (isequal (stk_distrib_normal_cdf ( 0.0), 0.5));
%!assert (isequal (stk_distrib_normal_cdf ( inf), 1.0));
%!assert (isequal (stk_distrib_normal_cdf (-inf), 0.0));
%!assert (isnan   (stk_distrib_normal_cdf ( nan)));
%!assert (isnan   (stk_distrib_normal_cdf (0, 0, -1)));
%!assert (isequal (stk_distrib_normal_cdf (0, 0, 0), 1.0));
%!assert (isequal (stk_distrib_normal_cdf (0, 1, 0), 0.0));
%!assert (isequal (stk_distrib_normal_cdf (1, 0, 0), 1.0));
