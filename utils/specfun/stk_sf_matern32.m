% STK_SF_MATERN32 computes the Matern function with nu=5/2
%
% FIXME: documentation missing
%
% if diff != -1 returns the derivative with respect to parameter
% number diff
%

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
function k = stk_sf_matern32(h, diff)

% default: compute the value (not a derivative)
if (nargin<2), diff = -1; end

Nu = 3/2;
C  = 2 * sqrt(Nu);   % dt/dh
t  = C * abs(h);

switch diff,
    
    case -1, % value of the covariance function
        
        k = (1 + t) .* exp(-t);
        
    case 1, % derivative wrt h
            
        k = - C * t .* exp(-t);

    otherwise
        
        error('incorrect value for diff.');
        
end

end

% TEST
% h = 0.1; stk_sf_matern(3/2,h), stk_sf_matern32(h)
% h = 0.1; stk_sf_matern(3/2,h,2), stk_sf_matern32(h,1)
