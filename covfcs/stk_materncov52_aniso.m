% STK_MATERNCOV52_ANISO computes the anisotropic Matern covariance with nu=5/2
%
% CALL: k = stk_materncov52_aniso(x, y, param, diff)
%   x      = structure whose field 'a' contains the observed points.
%            x.a  is a matrix of size n x d, where n is the number of
%            points and d is the dimension of the factor space
%   y      = same as x
%   param  = vector of parameters of size 1+d
%   diff   = differentiation parameter
%
% STK_MATERNCOV52_ANISO computes a Matern covariance between two random vectors
% specified by the locations of the observations. This anisotropic
% covariance function has 2+d parameters, where d is the dimension of the
% factor space. They are defined as follows:
%    param(1)   = log(sigma^2) is the logarithm of the variance
%    param(1+i) = -log(rho(i)) is  the logarithm of  the inverse  of  the
%                 i^th range parameter
%
% If diff ~= -1, the function returns the derivative of the covariance wrt
% param(diff)

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version: 1.0
%    Authors: Julien Bect <julien.bect@supelec.fr>
%             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:     http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function k = stk_materncov52_aniso(x, y, param, diff)

persistent x0 y0 xs ys param0 D Kx_cache compute_Kx_cache

% default: compute the value (not a derivative)
if (nargin<4), diff = -1; end

% extract parameters from the "param" vector
Sigma2 = exp(param(1));
invRho = exp(param(2:end));

% check parameter values
if ~(Sigma2>0) || ~all(invRho>0),
    error('Incorrect parameter value.');
end

invRho = diag(invRho);

% check if all input arguments are the same as before
% (or if this is the first call to the function)
if isempty(x0) || isempty(y0) || isempty(param0) || ...
        ~isequal({x.a,y.a,param},{x0.a,y0.a,param0})
    % compute the distance matrix
    xs = x.a * invRho; ys = y.a * invRho;
    D = stk_distance_matrix(xs, ys);
    % save arguments for the next call
    x0 = x; y0 = y; param0 = param;
    % recomputation of Kx_cache is required
    compute_Kx_cache = true;
end

if diff == -1,
    %%% compute the value (not a derivative)
    k = Sigma2 * stk_sf_matern52(D, -1);
elseif diff == 1,
    %%% diff wrt param(1) = log(Sigma2)
    k = Sigma2 * stk_sf_matern52(D, -1);
elseif diff >= 2,
    %%% diff wrt param(diff) = - log(invRho(diff-1))
    ind = diff - 1;
    if compute_Kx_cache || isempty(Kx_cache)
        Kx_cache  = 1./(D+eps) .* (Sigma2 * stk_sf_matern52(D, 1));
        compute_Kx_cache = false;
    end
    nx = size(x.a,1); ny = size(y.a,1);
    k = (repmat(xs(:,ind),1,ny) - repmat(ys(:,ind)',nx,1)).^2 .* Kx_cache;
else
    error('there must be something wrong here !');
end
