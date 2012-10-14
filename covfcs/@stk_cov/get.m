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

function t = get(cov, propertyname)

switch propertyname
    
    case 'name'
        t = cov.name;
        
    case 'param',  % get the whole 'param' descriptor at once
        t = stk_get_param(cov, []);
        
    case 'cparam', % get the whole 'cparam' vector at once
        t = stk_get_cparam(cov);
        
    otherwise
        try
            t = stk_get_param(cov, propertyname);
        catch %#ok<CTCH>
            stk_error(sprintf('No %s property to get in class %s.', propertyname, ...
                class(cov), propertyname), 'NonExistentProperty');
        end
        
end % switch


end % function set
