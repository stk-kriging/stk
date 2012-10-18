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

function t = get(cov, propname)

switch propname
    
    case {'param', 'handlers'}
        t = cov.prop.(propname);
                
    case 'name'
        t = get(cov.stk_cov, 'name');

    case 'cparam'
        
        param = cov.prop.param;
        get_cparam = cov.prop.handlers.get_cparam;
        
        if isempty(get_cparam), % no getter available... assume that cparam = param ?
            
            if isa(param, 'double'), % yes, we can
                t = param;
            else
                errmsg = 'Property ''cparam'' does not exist for this covariance.';
                stk_error(errmsg, 'cparamMissing');
            end
            
        else
            
            t = cov.get_cparam(cov.param);
            
        end % if
        
    otherwise % perhaps a specific property of this covariance ?

        param = cov.prop.param;
        get_param = cov.prop.handlers.get_param;
        
        if isempty(get_param), % no getter available, try direct indexing
            
            if isstruct(param) && isfield(param, propname)
                t = param.(propname);
            else
                errmsg = sprintf('Unable to get the value of property %s.', propname);
                stk_error(errmsg, 'InvalidArgument');
            end
            
        else % user user-provided getter
            
            t = get_param(param, propname);
            
        end

end % function get
