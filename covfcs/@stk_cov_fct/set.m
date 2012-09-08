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

function cov = set(cov, propertyname, value, varargin)

switch propertyname
    
    case 'nb_cparam'
        stk_error('Property nb_cparam is immutable.', 'SetImmutableProp');
        
    case 'param',
        cov = stk_set_param(cov, value, varargin{:});
        
    case 'cparam',
        cov = stk_set_cparam(cov, value, varargin{:});
        
    otherwise
        
        try % perhaps a "named" parameter ?
            
            cov = stk_set_param(cov, propertyname, value);

            % there should be no additional parameter in varargin
            if ~isempty(varargin)
                stk_error('Too many input arguments', 'TooManyInputArgs');
            end
            
        catch % OK, I give up
            
	  stk_error(sprintf('Class %s has no %s property to be set.', ...
                class(cov), propertyname), 'NonExistentProperty');
            
        end % try/catch
        
end

end % function set
