% STK_NOISECOV computes a noise covariance

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
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
function K = stk_noisecov(ni, lognoisevariance, diff)

s = size(lognoisevariance);
n = max(s);
if ~isequal(s, [1,n]) && ~isequal(s, [n,1])
    error('lognoisvariance must be a vector.');
end

if nargin == 2,
    diff = -1; % default: compute the value (not a derivative)
end

if n == 1
    % the result does not depend on diff
    K = exp(lognoisevariance) * eye(ni);
else
    if diff ~= -1,
        error('not implemented');
    end
    K = diag(exp(lognoisevariance));
end
