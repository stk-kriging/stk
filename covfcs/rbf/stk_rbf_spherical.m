% STK_RBF_SPHERICAL computes the spherical correlation function
%
% CALL: K = stk_rbf_spherical (H)
%
%    computes the value of the spherical correlation function at distance H:
%
%            /
%            |  1 - 3/2 |h| + 1/2 |h|^3     if |h| < 1,
%        K = |
%            |  0                           otherwise.
%            \
%
% CALL: K = stk_rbf_spherical (H, DIFF)
%
%    computes the derivative of the spherical correlation function with
%    respect the H if DIFF is equal to 1, and simply returns the value of the
%    exponential correlation function if DIFF <= 0  (in which case it is
%    equivalent to K = stk_rbf_spherical (H)).
%
% ADMISSIBILITY
%
%    The spherical correlation is a valid correlation function in
%    dimension d <= 3.

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%
%    Author:  Julien Bect   <julien.bect@centralesupelec.fr>

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

function k = stk_rbf_spherical (h, diff)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

t = abs (h);
b = (t < 1);
k = zeros (size (h));

if (nargin < 2) || (diff <= 0)
    
    % value of the spherical correlation at h
    k(b) = ((1 - t(b)) .^ 2) .* (1 + 0.5 * t(b));
    
elseif diff == 1
    
    % derivative of the spherical correlation function at h
    % (convention: k'(0) = 0, even though k is not derivable at h=0)
    k(b) = 1.5 * (sign (h(b))) .* (t(b) .^ 2 - 1);
    
else
    error ('incorrect value for diff.');
end

end % function


%!shared h, diff
%! h = 1.0;  diff = -1;

%!error stk_rbf_spherical ();
%!test  stk_rbf_spherical (h);
%!test  stk_rbf_spherical (h, diff);
%!error stk_rbf_spherical (h, diff, pi);

%!test %% h = 0.0 => correlation = 1.0
%! x = stk_rbf_spherical (0.0);
%! assert (stk_isequal_tolrel (x, 1.0, 1e-8));

%!test %% check derivative numerically
%! h = [-1 -0.5 -0.1 0.1 0.5 1];  delta = 1e-9;
%! d1 = (stk_rbf_spherical (h + delta) - stk_rbf_spherical (h)) / delta;
%! d2 = stk_rbf_spherical (h, 1);
%! assert (stk_isequal_tolabs (d1, d2, 1e-4));

%!assert (stk_rbf_spherical (inf) == 0)

