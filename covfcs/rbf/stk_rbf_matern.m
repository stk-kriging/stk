% STK_RBF_MATERN computes the Matern correlation function.
%
% CALL: K = stk_rbf_matern (NU, H)
%
%    computes the value of the Matern correlation function of order NU at
%    distance H. Note that the Matern correlation function is a valid
%    correlation function for all dimensions.
%
% CALL: K = stk_rbf_matern (NU, H, DIFF)
%
%    computes the derivative of the Matern correlation function of order NU, at
%    distance H, with respect to the order NU if DIFF is equal to 1, or with
%    respect the distance H if DIFF is equal to 2. (If DIFF is equal to -1,
%    this is the same as K = stk_rbf_matern(NU, H).)
%
% See also: stk_rbf_matern32, stk_rbf_matern52

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
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

function k = stk_rbf_matern (nu, h, diff)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% default: compute the value (not a derivative)
if nargin < 3,
    diff = -1;
end

if ~ ((isscalar (nu)) && (nu > 0))
    stk_error ('nu should be a positive scalar.', 'IncorrectSize');
end

% Handle the case of VERY large nu
if nu > 1e305,
    % nu = 1e306 is so large thatn even gammaln (nu) is not defined !
    if diff <= 0,
        k = stk_rbf_gauss (h);  return;
    else
        % Cannot compute or approximate the derivative for such a large nu
        k = nan (size (h)); return;
    end
end
        
% Tolerance for the detection of half-integer values of nu
TOL = 10 * eps;

% We have no analytical expression for the derivative with respect to nu,
% even if nu is 3/2, 5/2 or +Inf
if diff ~= 1,
    
    if abs (nu - 1.5) < TOL,
                
        k = stk_rbf_matern32 (h, diff - 1);  return;
        
    elseif abs (nu - 2.5) < TOL,
        
        k = stk_rbf_matern52 (h, diff - 1);  return;
               
    end
    
end

[N, M] = size (h);
hp = abs (reshape (h, N * M, 1));
t = 2 * sqrt (nu) * hp;
z = 0.5 * exp (gammaln (nu) - nu * log (0.5 * t));
I = ~ isinf (z);

if diff <= 0
    
    k = zeros (N * M, 1);
    
    % When z < +Inf, compute using the modified Bessel function of the second kind
    k(I) = 1 ./ z(I) .* besselk_ (nu, t(I));
    
    % When z == +Inf, it means nu is large and/or t is close to zero.
    % We approximate the result with the upper bound provided by the Gaussian case.
    k(~I) = stk_rbf_gauss (h(~I));
    
elseif diff == 1  % numerical derivative wrt Nu
    
    itermax = 2;
    delta = 1e-4;
    dk = zeros (N * M, itermax);
    for l= 1:itermax
        Nu_p = nu + 2 ^ (l - 1) * delta;
        Nu_m = nu - 2 ^ (l - 1) * delta;
        t_p = 2 * sqrt (Nu_p) * hp;
        t_m = 2 * sqrt (Nu_m) * hp;
        k_p = 1 / (2 ^ (Nu_p - 1) * gamma (Nu_p)) .* t_p(I) .^ Nu_p .* ...
            besselk_ (Nu_p, t_p(I));
        k_m = 1 / (2 ^ (Nu_m - 1) * gamma (Nu_m)) .* t_m(I) .^ Nu_m .* ...
            besselk_ (Nu_m, t_m(I));
        dk(I, l) =  k_p - k_m;
    end
    k = 1 / (12 * delta)* (- dk(:, 2) + 8 * dk(:, 1));
    
elseif diff == 2  % deriv. wrt h
    
    k = zeros (N * M, 1);
    dtdh = 2 * sqrt (nu);
    k(I)  = - dtdh ./ z(I) .* besselk_ (nu - 1, t(I));
    
end

k = reshape (k, N, M);

end % function


function y = besselk_ (nu, x)

opts = stk_options_get('stk_rbf_matern');

if size(x, 1) < opts.min_size_for_parallelization,
    y = besselk(nu, x);
else
    y = stk_parallel_feval(@(t)(besselk(nu, t)), x, true, opts.min_block_size);
end

end % function


%!shared nu, h, diff
%! nu = 1.0;  h = 1.0;  diff = -1;

%!error stk_rbf_matern ();
%!error stk_rbf_matern (nu);
%!test  stk_rbf_matern (nu, h);
%!test  stk_rbf_matern (nu, h, diff);
%!error stk_rbf_matern (nu, h, diff, pi);

%!test %% h = 0.0 => correlation = 1.0
%! for nu = 0.1:0.2:5.0,
%!   x = stk_rbf_matern (nu, 0.0);
%!   assert (stk_isequal_tolrel (x, 1.0, 1e-8));
%! end
