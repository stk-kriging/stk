% STK_EXPCOV_ANISO computes the anisotropic exponential covariance function
%
% CALL: K = stk_expcov_aniso (PARAM, X, Y)
%
%   computes the covariance matrix K between the sets of locations X and Y,
%   using the exponential covariance function with parameters PARAM. The output
%   matrix K has size NX x NY, where NX is the number of rows in X and NY the
%   number of rows in Y. The vector of parameters must have DIM + 1 elements,
%   where DIM is the common number of columns of X and Y:
%
%     * PARAM(1) = log (SIGMA ^ 2), where SIGMA is the standard deviation,
%
%     * PARAM(1+i) = - log (RHO(i)), where RHO(i) is the range parameter
%       for the ith dimension.
%
% CALL: dK = stk_expcov_aniso (PARAM, X, Y, DIFF)
%
%   computes the derivative of the covariance matrix with respect to
%   PARAM(DIFF) if DIFF~= -1, or the covariance matrix itself if DIFF is
%   equal to -1 (in which case this is equivalent to stk_materncov_aniso
%   (PARAM, X, Y)).
%
% CALL: K = stk_expcov_aniso (PARAM, X, Y, DIFF, PAIRWISE)
%
%   computes the covariance vector (or a derivative of it if DIFF > 0)
%   between the sets of locations X and Y.  The output K is a vector of
%   length N, where N is the common number of rows of X and Y.

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>
%              Paul Feliot       <paul.feliot@irt-systemx.fr>

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

function k = stk_expcov_aniso (param, x, y, diff, pairwise)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

persistent x0 y0 xs ys param0 pairwise0 D Kx_cache compute_Kx_cache

% process input arguments
x = double (x);
y = double (y);
if nargin < 4, diff = -1; end
if nargin < 5, pairwise = false; end

% check consistency for the number of factors
dim = size (x, 2);
if (size (y, 2) ~= dim),
    stk_error ('xi and yi have incompatible sizes.', 'InvalidArgument');
end

% check param
nb_params = dim + 1;
if (numel (param) ~= nb_params)
    stk_error ('xi and param have incompatible sizes.', 'InvalidArgument');
else
    param = reshape (param, 1, nb_params);  % row vector
end

% extract parameters from the "param" vector
Sigma2 = exp (param(1));
invRho = exp (param(2:end));

% check parameter values
if ~ (Sigma2 > 0) || ~ all (invRho >= 0),
    error ('Incorrect parameter value.');
end

% check if all input arguments are the same as before
% (or if this is the first call to the function)
if isempty (x0) || isempty (y0) || isempty (param0) ...
        || ~ isequal ({x, y, param}, {x0, y0, param0}) ...
        || ~ isequal (pairwise, pairwise0)
    % compute the distance matrix
    xs = bsxfun (@times, x, invRho);
    ys = bsxfun (@times, y, invRho);
    D = stk_dist (xs, ys, pairwise);
    % save arguments for the next call
    x0 = x;  y0 = y;  param0 = param;  pairwise0 = pairwise;
    % recomputation of Kx_cache is required
    compute_Kx_cache = true;
end

if diff == -1,
    %%% compute the value (not a derivative)
    k = Sigma2 * stk_rbf_exponential (D, -1);
elseif diff == 1,
    %%% diff wrt param(1) = log(Sigma2)
    k = Sigma2 * stk_rbf_exponential (D, -1);
elseif (diff >= 2) && (diff <= nb_params),
    %%% diff wrt param(diff) = - log(invRho(diff-1))
    ind = diff - 1;
    if compute_Kx_cache || isempty (Kx_cache)
        Kx_cache  = 1 ./ (D + eps) .* (Sigma2 * stk_rbf_exponential (D, 1));
        compute_Kx_cache = false;
    end
    if pairwise,
        k = (xs(:, ind) - ys(:, ind)).^2 .* Kx_cache;
    else
        k = (bsxfun (@minus, xs(:, ind), ys(:, ind)')) .^ 2 .* Kx_cache;
    end
else
    stk_error ('Incorrect value for the ''diff'' parameter.', ...
        'InvalidArgument');
end

end % function


%%
% 1D, 5x5

%!shared param, x, y, K1, K2, K3
%! dim = 1;
%! param = log ([1.0; 2.5]);
%! x = stk_sampling_randunif (5, dim);
%! y = stk_sampling_randunif (6, dim);

%!error K0 = stk_expcov_aniso ();
%!error K0 = stk_expcov_aniso (param);
%!error K0 = stk_expcov_aniso (param, x);
%!test  K1 = stk_expcov_aniso (param, x, y);
%!test  K2 = stk_expcov_aniso (param, x, y, -1);
%!test  K3 = stk_expcov_aniso (param, x, y, -1, false);
%!error K0 = stk_expcov_aniso (param, x, y, -1, false, pi^2);
%!assert (isequal (K1, K2));
%!assert (isequal (K1, K3));

%!test  % df versus ordinary array
%! u = double (x);  v = double (y);
%! K1 = stk_expcov_aniso (param, u, v, -1);
%! K2 = stk_expcov_aniso (param, stk_dataframe (u), stk_dataframe (v), -1);

%!error stk_expcov_aniso (param, x, y, -2);
%!test  stk_expcov_aniso (param, x, y, -1);
%!error stk_expcov_aniso (param, x, y,  0);
%!test  stk_expcov_aniso (param, x, y,  1);
%!test  stk_expcov_aniso (param, x, y,  2);
%!error stk_expcov_aniso (param, x, y,  3);
%!error stk_expcov_aniso (param, x, y,  nan);
%!error stk_expcov_aniso (param, x, y,  inf);

%%
% 3D, 4x10

%!shared dim, param, x, y, nx, ny
%! dim = 3;
%! param = log ([1.0; 2.5; 2.4; 2.6]);
%! nx = 4;  ny = 10;
%! x = stk_sampling_randunif (nx,  dim);
%! y = stk_sampling_randunif (ny, dim);

%!test
%! K1 = stk_expcov_aniso (param, x, y);
%! K2 = stk_expcov_aniso (param, x, y, -1);
%! assert (isequal (size(K1), [nx ny]));
%! assert (stk_isequal_tolabs (K1, K2));

%!test
%! for i = 1:(dim + 1),
%!     dK = stk_expcov_aniso (param, x, y,  i);
%!     assert (isequal (size (dK), [nx ny]));
%! end

%!test
%! n = 7;
%! x = stk_sampling_randunif (n, dim);
%! y = stk_sampling_randunif (n, dim);
%!
%! K1 = stk_expcov_aniso (param, x, y);
%! K2 = stk_expcov_aniso (param, x, y, -1, true);
%! assert (isequal (size (K1), [n n]));
%! assert (stk_isequal_tolabs (K2, diag (K1)));
%!
%! for i = 1:(dim + 1),
%!     dK1 = stk_expcov_aniso (param, x, y,  i);
%!     dK2 = stk_expcov_aniso (param, x, y,  i, true);
%!     assert (isequal (size (dK1), [n n]));
%!     assert (stk_isequal_tolabs (dK2, diag (dK1)));
%! end
