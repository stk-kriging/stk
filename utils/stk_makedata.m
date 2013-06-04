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
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function S = stk_makedata(x, z, noisevariance)

%--- handle first input argument ----------------------------------------------

if isstruct(x)   
    if isfield(x, 'v'),
        stk_error('This kind of .v field is not supported anymore.', ...
            'ObsoleteFeature');
    else
        % (try to) get the data from an old-style STK structure
        x = x.a;
    end
end

n = size(x, 1);

%--- handle second input argument ---------------------------------------------

if isstruct(z)
    % (try to) get the data from an old-style STK structure
    z = z.a;
end

if ~isempty(z) && (size(z, 1) ~= n),
    errmsg = 'x and z should have the same number of rows.';
    stk_error(errmsg, 'IncorrectArgument');
end

%--- create the output structure ----------------------------------------------

S = struct('x', x, 'z', z, 'n', n);

if nargin == 3,
    if noisevariance > 0,
        % the observations are assumed to be noisy
        S.noisy_obs = 'Y';
        S.noise_variance = noisevariance;
    else
        % the observations are assumed to be noiseless
        S.noisy_obs = 'N';
    end
else
    % we don't known if the observations must be assumed to be noisy
    S.noisy_obs = '?';
end

end
