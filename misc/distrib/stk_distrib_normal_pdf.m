% STK_DISTRIB_NORMAL_PDF  [STK internal]

% Copyright Notice
%
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

function density = stk_distrib_normal_pdf (z, mu, sigma)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 1,
    z = bsxfun (@minus, z, mu);
end

if nargin > 2,
    [z, sigma] = stk_commonsize (z, sigma);
    z = z ./ sigma;
    k0 = (sigma > 0);
else
    sigma = 1;
    k0 = 1;
end

xx = z .^ 2;
density = nan (size (z));

k0 = k0 & (~ isnan (z));
kb = (xx > 1491);  % when x^2 > 1491, the result is 0 in double precision

% Deal with "large" values of abs(x)
k = k0 & kb;
density(k) = 0;

% Deal with "small" values of abs(x)
k = k0 & (~ kb);
density(k) = 0.39894228040143268 * exp (- 0.5 * xx(k));

density = bsxfun (@rdivide, density, sigma);

end % function


%!assert (stk_isequal_tolrel (stk_distrib_normal_pdf ([1; 3], 1, [1 10]),  ...
%!                 [1 / sqrt(2 * pi)        ...  % normpdf ((1 - 1) / 1)
%!                  0.1 / sqrt(2 * pi);     ...  % normpdf ((1 - 1) / 10) / 10
%!                  exp(-2) / sqrt(2 * pi)  ...  % normpdf ((3 - 1) / 1)
%!                  3.910426939754558780e-2 ...  % normpdf ((3 - 1) / 10) / 10
%!                 ], eps));

%!assert (isequal (stk_distrib_normal_pdf (inf), 0.0));
%!assert (isequal (stk_distrib_normal_pdf (-inf), 0.0));
%!assert (isnan   (stk_distrib_normal_pdf (nan)));
%!assert (isnan   (stk_distrib_normal_pdf (0, 0, -1)));
