% GET_LOGNOISEVARIANCE [internal]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function lnv = get_lognoisevariance (model, xg, x, x_is_index)

if nargin < 4,
    x_is_index = false;
end

if isa (xg, 'stk_ndf') % heteroscedatic case

    if x_is_index
        pos = x;
    else
        [b, pos] = ismember (x, xg, 'rows');
        assert (all (b));
    end
    
    lnv = log (xg.noisevariance(pos));

else % homoscedastic case
    
    lnv = model.lognoisevariance;
    assert (isscalar (lnv));
    
end

end % function
