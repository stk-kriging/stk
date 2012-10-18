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

function cov = set(cov, propname, value)

switch propname
    
    case {'param', 'handlers'}
        cov.prop.(propname) = value;
        
    case 'name'
        cov.stk_cov = set(cov.stk_cov, 'name', value);
        
    case 'cparam'
        
        param = cov.prop.param;
        set_cparam = cov.prop.handlers.set_cparam;
        
        % check that value is a vector of type double, and make it a column
        if isa(value, 'double')
            if numel(value) == length(value)
                if size(value, 1) ~= length(value)
                    msg = 'Property ''cparam'' expects a COLUMN vector.';
                    msg = sprintf('%s\nTransposing line vector...', msg);
                    warning(msg);  value = value(:);
                end
            else
                errmsg = 'Property ''cparam'' expects a (column) vector.';
                stk_error(errmsg, 'IncorrectArgument');
            end
        else
            errmsg = 'Property ''cparam'' expects type double.';
            stk_error(errmsg, 'IncorrectArgument');
        end
                    
        if isempty(set_cparam), % no setter available... assume that cparam = param ?
                        
            if isa(param, 'double') && (size(param, 1) == length(param))
                % ok, param is column vector, let's assume that cparam = param
                if length(param) == length(value)
                    cov.prop.param = value;
                else
                    errmsg = 'Incorrect size for the value of ''cparam''.';
                    stk_error(errmsg, 'IncorrectArgument');
                end                
            else
                errmsg = 'Unable to set property ''cparam'' for this covariance.';
                stk_error(errmsg, 'CParamMissing');
            end
            
        else % user user-provided setter
            
            cov.prop.param = set_cparam(param, value);
            
        end % if
        
    otherwise % perhaps a specific property of this covariance ?

        param = cov.prop.param;
        set_param = cov.prop.handlers.set_param;
        
        if isempty(set_param), % no setter available, try direct indexing
            
            if isstruct(param) && isfield(param, propname)
                cov.prop.param.(propname) = value;
            else
                errmsg = sprintf('Unable to set the value of property %s.', propname);
                stk_error(errmsg, 'InvalidArgument');
            end
            
        else % user user-provided getter
            
            cov.prop.param = set_param(param, propname, value);
            
        end
      
end % switch

end % function set
