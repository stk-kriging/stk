% STK_RBF_MATERN32 computes the Matern correlation function of order 3/2.
%
% CALL: K = stk_rbf_matern32 (H)
%
%    computes the value of the Matern correlation function of order 3/2 at
%    distance H. Note that the Matern correlation function is a valid
%    correlation function for all dimensions.
%
% CALL: K = stk_rbf_matern32 (H, DIFF)
%
%    computes the derivative of the Matern correlation function of order 3/2, at
%    distance H, with respect the distance H if DIFF is equal to 1. (If DIFF is
%    equal to -1, this is the same as K = stk_rbf_matern32(H).)
%
% See also: stk_rbf_matern, stk_rbf_matern52

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function k = stk_rbf_matern32 (h, diff)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% default: compute the value (not a derivative)
if nargin < 2,
    diff = -1;
end

Nu = 3/2;
C  = 2 * sqrt (Nu);   % dt/dh
t  = C * abs (h);

k = exp (- t);
b = (k > 0);

if diff <= 0,  % value of the covariance function
    
    k(b) = (1 + t(b)) .* k(b);
    
elseif diff == 1,  % derivative wrt h
    
    k(b) = - C * t(b) .* k(b);
    
else
    
    error ('incorrect value for diff.');
    
end

end % function


%!shared h, diff
%! h = 1.0;  diff = -1;

%!error stk_rbf_matern32 ();
%!test  stk_rbf_matern32 (h);
%!test  stk_rbf_matern32 (h, diff);
%!error stk_rbf_matern32 (h, diff, pi);

%!test %% h = 0.0 => correlation = 1.0
%! x = stk_rbf_matern32 (0.0);
%! assert (stk_isequal_tolrel (x, 1.0, 1e-8));

%!test %% consistency with stk_rbf_matern: function values
%! for h = 0.1:0.1:2.0,
%!   x = stk_rbf_matern (3/2, h);
%!   y = stk_rbf_matern32 (h);
%!   assert (stk_isequal_tolrel (x, y, 1e-8));
%! end

%!test %% consistency with stk_rbf_matern: derivatives
%! for h = 0.1:0.1:2.0,
%!   x = stk_rbf_matern (3/2, h, 2);
%!   y = stk_rbf_matern32 (h, 1);
%!   assert (stk_isequal_tolrel (x, y, 1e-8));
%! end

%!assert (stk_rbf_matern32 (inf) == 0)

