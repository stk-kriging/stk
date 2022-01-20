% STK_DISTRIB_LOGPDF [STK internal]
%
% Trying to make things cleaner, until we finally develop an elegant system of
% probability distribution objects...
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal.  Please be aware that
%    API-breaking changes are likely to happen in future releases.

% Copyright Notice
%
%    Copyright (C) 2016, 2018 CentraleSupelec
%    Copyright (C) 2016 LNE
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Remi Stroh   <remi.stroh@lne.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function logpdf = stk_distrib_logpdf (distrib, z)

delta = z - distrib.mean;

if isfield (distrib, 'invcov')
    
    % We assume (but do not check) that .var is absent or compatible with invcov...
    
    logpdf = - 0.5 * (delta' * distrib.invcov * delta);
    
else  % assume isfield (distrib, 'var')
    
    logpdf = - 0.5 * (delta' * (distrib.var \ delta));
    
end

end % function
