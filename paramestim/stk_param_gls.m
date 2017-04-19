% STK_PARAM_GLS computes a generalised least squares estimate
%
% CALL: BETA = stk_param_gls (MODEL, XI, ZI)
%
%   computes the generalised least squares estimate BETA of the vector of
%   coefficients for the linear part of MODEL, where XI and ZI stand for
%   the evaluation points and observed responses, respectively.
%
% CALL: [BETA, SIGMA2] = stk_param_gls (MODEL, XI, ZI)
%
%   also returns the associated unbiased estimate SIGMA2 of sigma^2, assu-
%   ming that the actual covariance matrix of the Gaussian process part of
%   the model is sigma^2 K, with K the covariance matrix built from MODEL.
%
%   SIGMA2 is actually the "best" unbiased estimate of sigma^2 :
%
%                 1
%      SIGMA2 = ----- * || ZI - P BETA ||^2_{K^{-1}}
%               n - r
%
%   where n is the number of observations, r the length of BETA, P the
%   design matrix for the linear part of the model, and || . ||_{K^{-1}}
%   the norm associated to the positive definite matrix K^{-1}. It is the
%   best estimate with respect to the quadratic risk, among all unbiased
%   estimates which are quadratic in the residuals.

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>
%              Ashwin Ravisankar  <ashwinr1993@gmail.com>

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

function [beta, sigma2, L] = stk_param_gls (model, xi, zi)

n = size (xi, 1);

% Build the covariance matrix and the design matrix
[K, P] = stk_make_matcov (model, xi);

% Cast zi into a double-precision array
zi = double (zi);

% Compute the Generalized Least Squares (GLS) estimate
L = stk_cholcov (K, 'lower');
W = L \ P;
u = L \ zi;
beta = (W' * W) \ (W' * u);

if nargin > 1,
    % Assuming that the actual covariance matrice is sigma^2 K, compute the
    % "best" unbiased estimate of sigma2 (best wrt the quadratic risk, among
    % all unbiased estimates which are quadratic in the residuals)
    r = length (beta);
    sigma2 = 1 / (n - r) * sum ((u - W * beta) .^ 2);
end

end % end function stk_param_gls


%!shared xi, zi, model, beta, sigma2
%! xi = (1:10)';  zi = sin (xi);
%! model = stk_model ('stk_materncov52_iso');
%! model.param = [0.0 0.0];

%!test
%! model.lm = stk_lm_constant ();
%! [beta, sigma2] = stk_param_gls (model, xi, zi);
%!assert (stk_isequal_tolabs (beta, 0.1346064, 1e-6))
%!assert (stk_isequal_tolabs (sigma2,  0.4295288, 1e-6))

%!test
%! model.lm = stk_lm_affine ();
%! [beta, sigma2] = stk_param_gls (model, xi, zi);
%!assert (stk_isequal_tolabs (beta, [0.4728342; -0.0614960], 1e-6))
%!assert (stk_isequal_tolabs (sigma2, 0.4559431, 1e-6))

%!test
%! model.lm = stk_lm_null ();
%! [beta, sigma2] = stk_param_gls (model, xi, zi);
%!assert (isequal (beta, zeros (0, 1)))
%!assert (stk_isequal_tolabs (sigma2, 0.3977993, 1e-6))
