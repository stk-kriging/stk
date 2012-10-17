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

function t = stk_get_param(cov, propertyname)

if isempty(propertyname), % "full parameter"
    
    t = cov.param;
    
else
    
    if isfield(cov.param, propertyname)
        % FIXME: argument checking
        t = cov.param.(propertyname);        
    else % perhaps a property of the base covariance ?        
        try            
            t = stk_get_param(cov.param.base_cov, propertyname);
        catch
            errmsg = sprintf('Property %s does not exist.', propertyname);
            stk_error(errmsg, 'IncorrectArgument');
        end        
    end

end % if

end % function stk_get_param