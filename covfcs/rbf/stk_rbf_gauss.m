% STK_RBF_GAUSS computes the Gaussian correlation function
%
% CALL: K = stk_rbf_gauss (H)
%
%    computes the value of the Gaussian correlation function at distance H.
%
% CALL: K = stk_rbf_gauss (H, DIFF)
%
%    computes the derivative  of the Gaussian correlation function  with respect
%    to the distance H  if DIFF is equal to 1.  If DIFF is equal to -1,  this is
%    the same as K = stk_rbf_gauss (H).
%
% NOTES:
%
%  * This correlation function is also known as the "squared exponential" corre-
%    lation function, or the "Gaussian RBF" (Radial Basis Function).
%
%  * The Gaussian correlation function is  a valid correlation function  for all
%    dimensions.
%
%  * The Gaussian correlation function  is  the limit of  the Matern correlation
%    function when the regularity parameters tends to infinity.
%
% See also: stk_rbf_matern, stk_rbf_matern52

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
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

function k = stk_rbf_gauss (h, diff)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% default: compute the value (not a derivative)
if nargin < 2,
    diff = -1;
end

if diff <= 0,  % value of the covariance function
    
    k = exp (- h .^ 2);
    
elseif diff == 1,  % derivative wrt h
    
    k = - 2 * h .* exp (- h .^ 2);
    
else
    
    error ('incorrect value for diff.');
    
end

end % function


%!shared h, diff
%! h = 1.0;  diff = -1;

%!error stk_rbf_gauss ();
%!test  stk_rbf_gauss (h);
%!test  stk_rbf_gauss (h, diff);
%!error stk_rbf_gauss (h, diff, pi);

%!test  % h = 0.0 => correlation = 1.0
%! x = stk_rbf_gauss (0.0);
%! assert (stk_isequal_tolrel (x, 1.0, 1e-8));
