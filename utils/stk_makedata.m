% STK_MAKEDATA creates a data structure from points and evaluation results
%
% CALL: XZ = stk_makedata(X, Z)
%       X = matrix or structure (see below)
%       Z = matrix or structure (see below)
%       XZ = structure 
%            XZ.n = number of evaluations
%            XZ.x = structure of evaluation points whose field 'a' contains
%                   evaluation points
%            XZ.z = structure of evaluation results whose field 'a'
%                   contains evaluation results
%
%    creates a data structure XZ from evaluation points X and corresponding
%    evaluation results Z. X can be either a matrix or a structure whose
%    field 'a' contains evaluations points. Z can be either a matrix or a
%    structure whose field 'a' contains results.
%
% EXAMPLE:
%       f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );
%       xt.a = linspace ( 0, 1, 100 );
%       zt = stk_feval( f, xt );
%       xz = stk_makedata( xt, zt)
%       plot(xz.x.a, xz.z.a);
%
% See also stk_feval

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

function xz = stk_makedata(x, z, noisevariance)

if isstruct(x),
    xz.x = x;
    if isfield(x, 'v'),
       stk_error('.v fields are not supported anymore.', 'ObsoleteFeature');
    end
else  % we assume that the input x is a matrix here
    xz.x.a = x;
end

if isstruct(z),
    xz.z = z;
    if isfield(x, 'v'),
       stk_error('.v fields are not supported anymore.', 'ObsoleteFeature');
    end    
else % we assume that the input z is a matrix here
    xz.z.a = z;
end 
xz.n = size(xz.x.a, 1);

% sanity check
assert(xz.n == size(xz.z.a, 1));

if nargin == 3,
    if noisevariance > 0,
        % the observations are assumed to be noisy
        xz.noisy_obs = 'Y';
        xz.noise_variance = noisevariance;
    else
        % the observations are assumed to be noiseless
        xz.noisy_obs = 'N';
    end
else
    % we don't known if the observations must be assumed to be noisy
    xz.noisy_obs = '?';
end

end