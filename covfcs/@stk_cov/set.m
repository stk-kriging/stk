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
    
    case 'name'
        cov.prop.name = value;
        
    case 'cparam',   
        if ~isempty(value),
            errmsg = 'Property cparam is immutable for stk_cov objects.';            
            stk_error(errmsg, 'SettingImmutableProperty');
        end
        
    otherwise
        errmsg = sprintf('Class %s has no %s property to be set.', class(cov), propname);
        stk_error(errmsg, 'NonExistentProperty');
        
end

end % function set
