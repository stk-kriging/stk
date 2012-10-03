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

function t = get(cov, propertyname, varargin)

switch propertyname
    
    case 'name'
        t = cov.name;
        
    case 'nb_cparam'
        t = stk_get_nb_cparam(cov);
        
    case 'param',
        t = stk_get_param(cov, varargin{:});
        
    case 'cparam',
        t = stk_get_cparam(cov, varargin{:});
        
    otherwise
        
        try % perhaps a "named" parameter ?
            
            t = stk_get_param(cov, propertyname);
            % there should be no additional parameter in varargin
            if ~isempty(varargin)
                stk_error('Too many input arguments', 'TooManyInputArgs');
            end
            
        catch % OK, I give up
            
            stk_error(sprintf('No %s property to get in class %s.', propertyname, ...
                class(cov), propertyname), 'NonExistentProperty');
            
        end % try/catch
        
end % switch

end % function set
