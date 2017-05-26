% @STK_SAMPCRIT_AKG/SET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function crit = set (crit, propname, value)

switch propname
    
    case 'model'
        crit.model = value;
        crit = compute_zr_data (crit);
        
    case 'reference_grid'
        crit.reference_grid = double (value);
        if ~ isempty (crit.model)
            crit = compute_zr_data (crit);
        end
        
    otherwise
        
        errmsg = sprintf ('There is no property named %s', propname);
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function


function crit = compute_zr_data (crit)

if isempty (crit.model)
    
    crit.xr          = [];
    crit.zr_mean     = [];
    crit.zr_std      = [];
    crit.zr_lambdamu = [];
    
else
    
    if isempty (crit.reference_grid)
        crit.xr = get_input_data (crit.model);
    else
        crit.xr = crit.reference_grid;
    end
    
    if isstruct (crit.model)
        % Prior model described by a structure (currently considered as improper
        % prior, since we have no way of distinguishing between proper and
        % improper priors...)
        crit.zr_mean     = [];
        crit.zr_std      = [];
        crit.zr_lambdamu = [];
    else
        [zp, lambda, mu] = stk_predict (crit.model, crit.xr);
        crit.zr_mean     = zp.mean;
        crit.zr_std      = sqrt (zp.var);
        crit.zr_lambdamu = [lambda; mu];
    end
    
    % WARNING: the "mu" component of this lambdamu vector might be affected by a
    % scaling introduced by the kreq object.  Do not use directly.
    
end

end % function
