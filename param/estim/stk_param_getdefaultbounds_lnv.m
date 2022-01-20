% STK_PARAM_GETDEFAULTBOUNDS_LNV [STK internal]

% Copyright Notice
%
%    Copyright (C) 2017, 2018 CentraleSupelec
%    Copyright (C) 2017 LNE
%    Copyright (C) 2012 SUPELEC
%
%    Authors:  Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>
%              Remi Stroh        <remi.stroh@lne.fr>
%              Julien Bect       <julien.bect@centralesupelec.fr>

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

function [lb_lnv, ub_lnv] = stk_param_getdefaultbounds_lnv ...
    (model, lnv0, xi, zi) %#ok<INUSL>

if isnumeric (lnv0)
    
    if isscalar (lnv0)
        
        TOLVAR = 0.5;
        
        % Bounds for the variance parameter
        empirical_variance = var (zi);
        lb_lnv = log (eps);
        ub_lnv = log (empirical_variance) + TOLVAR;
        
        % Make sure that lnv0 falls within the bounds
        if ~ isempty (lnv0)
            lb_lnv = min (lb_lnv, lnv0 - TOLVAR);
            ub_lnv = max (ub_lnv, lnv0 + TOLVAR);
        end
        
    else
        
        lb_lnv = [];
        ub_lnv = [];
        
    end
    
else  % parameter object
    
    [lb_lnv, ub_lnv] = stk_param_getdefaultbounds (lnv0, xi, zi);
    
end

end % function
