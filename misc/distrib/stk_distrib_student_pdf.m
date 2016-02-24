% STK_DISTRIB_STUDENT_PDF  [STK internal]

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
%
%    This code is very loosely based on Octave's tpdf function:
%       ## Copyright (C) 2012 Rik Wehbring
%       ## Copyright (C) 1995-2012 Kurt Hornik

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

function density = stk_distrib_student_pdf (z, nu, mu, sigma)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 2,
    z = bsxfun (@minus, z, mu);
end

if nargin > 3,
    z = bsxfun (@rdivide, z, sigma);
else
    sigma = 1;
end

C = sqrt (nu) .* beta (nu / 2, 0.5);

if isscalar (nu)
    if nu == +inf
        % Gaussian case (nu = +inf)
        density = 0.39894228040143268 * exp (- 0.5 * (z .^ 2));
    else
        % Student case (nu < +inf)
        density = exp (- 0.5 * (nu + 1) * log (1 + z .^ 2 / nu)) / C;
    end
else
    [z, nu, C] = stk_commonsize (z, nu, C);
    density = nan (size (z));
    % Gaussian case (nu = +inf)
    k = (nu == +inf);
    density(k) = 0.39894228040143268 * exp (- 0.5 * (z(k) .^ 2));
    % Student case (nu < +inf)
    k = (nu > 0);  nu = nu(k);
    density(k) = exp (- 0.5 * (nu + 1) .* log (1 + z(k) .^ 2 ./ nu)) ./ C(k);
end

density = bsxfun (@rdivide, density, sigma);

end % function


%!assert (stk_isequal_tolrel ( ...
%!                 stk_distrib_student_pdf ([1; 3], [1; 2], [0 1], [1 10]), ...
%!                 [0.50 / pi              ...  % tpdf ((1 - 1) / 10, 1)
%!                  0.10 / pi;             ...  % tpdf ((1 - 1) / 10, 1) / 10
%!                  1 / (11 * sqrt(11))    ...  % tpdf ((3 - 0) /  1, 2) /  1
%!                  3.4320590294804165e-02 ...  % tpdf ((3 - 1) / 10, 2) / 10
%!                 ], eps));

%!assert (isequal (stk_distrib_student_pdf ( inf, 1.0), 0.0));
%!assert (isequal (stk_distrib_student_pdf (-inf, 1.0), 0.0));
%!assert (isnan   (stk_distrib_student_pdf ( nan, 1.0)));
