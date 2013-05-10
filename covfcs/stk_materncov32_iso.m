% STK_MATERNCOV32_ISO computes the isotropic Matern covariance
%
% CALL: k = stk_materncov52_iso(x, y, param, diff)
%   x      = structure whose field 'a' contains the observed points.
%            x.a  is a matrix of size n x d, where n is the number of 
%            points and d is the dimension of the 
%            factor space
%   y      = same as x
%   param  = vector of parameters of size 2
%   diff   = differentiation parameter
%
% STK_MATERNCOV32_ISO computes a Matern covariance between two random vectors
% specified by the locations of the observations. The isotropic covariance
% function has three parameters
%    param(1) = log(sigma^2) is the logarithm of the variance of random
%               process
%    param(2) = -log(rho) is the logarithm of the inverse of the range
%               parameter
% If diff ~= -1, the function returns the derivative of the covariance wrt
% param(diff)

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
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
function k = stk_materncov32_iso(x, y, param, diff)

persistent x0 y0 param0 D

% default: compute the value (not a derivative)
if (nargin<4), diff = -1; end

% extract parameters from the "param" vector
Sigma2 = exp(param(1));
invRho = exp(param(2));

% check parameter values
if ~(Sigma2>0) || ~(invRho>0),
    error('Incorrect parameter value.');
end

% check if all input arguments are the same as before
% (or if this is the first call to the function)
if isempty(x0) || isempty(y0) || isempty(param0) || ...
        ~isequal({x.a,y.a,param},{x0.a,y0.a,param0})
    % compute the distance matrix
    D  = invRho * stk_distance_matrix(x.a,y.a);
    % save arguments for the nex call
    x0 = x; y0 = y; param0 = param;
end

if diff == -1,
    %%% compute the value (not a derivative)
    k = Sigma2 * stk_sf_matern32(D, -1);
elseif diff == 1,
    %%% diff wrt param(1) = log(Sigma2)
    k = Sigma2 * stk_sf_matern32(D, -1);    
elseif diff == 2,
    %%% diff wrt param(3) = - log(invRho)
    k = D .* (Sigma2 * stk_sf_matern32(D, 1));
else
    error('there must be something wrong here !');
end
