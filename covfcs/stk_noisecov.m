% STK_NOISECOV computes a noise covariance

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

function K = stk_noisecov (ni, lognoisevariance, diff)

if nargin > 3,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 3,
    diff = -1; % default: compute the value (not a derivative)
end

if isscalar (lognoisevariance), % homoscedastic
    
    % the result does not depend on diff
    K = exp(lognoisevariance) * eye(ni);
    
else % heteroscedastic
    
    if ~ ((isequal (s, [1, ni])) || (isequal (s, [ni, 1])))
        error ('lognoisevariance must be a scalar or a vector of length ni.');
    end

    if diff ~= -1,
        error ('diff ~= -1 is not allowed in the heteroscedastic case');
    end
    
    K = diag (exp (lognoisevariance));
end

end % function


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared ni, lognoisevariance, diff
%!  ni = 5;
%!  lognoisevariance = 0.0;
%!  diff = -1;

%!error K = stk_noisecov();
%!error K = stk_noisecov(ni);
%!test  K = stk_noisecov(ni, lognoisevariance);
%!test  K = stk_noisecov(ni, lognoisevariance, diff);
%!error K = stk_noisecov(ni, lognoisevariance, diff, pi^2);
