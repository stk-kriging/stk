% STK_RBF_EXPONENTIAL computes the exponential correlation function
%
% CALL: K = stk_rbf_exponential (H)
%
%    computes the value of the exponential correlation function at distance H:
%
%        K = exp (- sqrt(2) |H|).
%
%    Note that this correlation function is a special of the Matern correlation
%    function (NU = 1/2).
%
% CALL: K = stk_rbf_exponential (H, DIFF)
%
%    computes the derivative of the exponential correlation function with
%    respect the H if DIFF is equal to 1, and simply returns the value of the
%    exponential correlation function if DIFF <= 0  (in which case it is
%    equivalent to K = stk_rbf_exponential (H)).
%
% ADMISSIBILITY
%
%    The exponential correlation is a valid correlation function for all
%    dimensions.
%
% REMARK
%
%    The constant sqrt (2) is consistent with the definition of the Matern
%    correlation function in STK.  Other references may use different constants.
%
% See also: stk_rbf_matern, stk_rbf_matern32, stk_rbf_matern52

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

function k = stk_rbf_exponential (h, diff)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

C = 1.4142135623730951;  % 2 * sqrt (Nu) with Nu = 1/2

% value of the exponential correlation at h
k = exp (- C * abs (h));

% for diff <= 0, we return the value of the correlation function; otherwise...
if (nargin > 1) && (diff > 0)
    % for diff == 1, we return the derivative
    if diff == 1
        b = (k > 0);
        % convention: k'(0) = 0, even though k is not derivable at h=0
        k(b) = - C * (sign (h(b))) .* k(b);
    else
        error ('incorrect value for diff.');
    end
    
end

if any (isnan (k))
    keyboard
end

end % function


%!shared h, diff
%! h = 1.0;  diff = -1;

%!error stk_rbf_exponential ();
%!test  stk_rbf_exponential (h);
%!test  stk_rbf_exponential (h, diff);
%!error stk_rbf_exponential (h, diff, pi);

%!test %% h = 0.0 => correlation = 1.0
%! x = stk_rbf_exponential (0.0);
%! assert (stk_isequal_tolrel (x, 1.0, 1e-8));

%!test %% check derivative numerically
%! h = [-1 -0.5 -0.1 0.1 0.5 1];  delta = 1e-9;
%! d1 = (stk_rbf_exponential (h + delta) - stk_rbf_exponential (h)) / delta;
%! d2 = stk_rbf_exponential (h, 1);
%! assert (stk_isequal_tolabs (d1, d2, 1e-4));

%!test %% consistency with stk_rbf_matern: function values
%! for h = 0.1:0.1:2.0,
%!   x = stk_rbf_matern (1/2, h);
%!   y = stk_rbf_exponential (h);
%!   assert (stk_isequal_tolrel (x, y, 1e-8));
%! end

%!test %% consistency with stk_rbf_matern: derivatives
%! for h = 0.1:0.1:2.0,
%!   x = stk_rbf_matern (1/2, h, 2);
%!   y = stk_rbf_exponential (h, 1);
%!   assert (stk_isequal_tolrel (x, y, 1e-8));
%! end

%!assert (stk_rbf_exponential (inf) == 0)

