% STK_SETNOISEVARIANCE ...

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:   Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function x = stk_setnoisevariance (x, noisevariance)

assert(isscalar(noisevariance), 'STK:setnoisevariance', ...
    'Error: noisevariance must be scalar');
x.noisevariance = noisevariance * ones(stk_length(x), 1);

end % function stk_setnoisevariance
