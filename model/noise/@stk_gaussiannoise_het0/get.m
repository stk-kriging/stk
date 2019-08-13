% GET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function value = get (gn, propname)

switch propname
    
    case {'log_dispersion', 'variance_function'}
        value = gn.(propname);
        
    case 'dispersion'
        value = exp (gn.log_dispersion);
        
    otherwise
        if ~ ischar (propname)
            errmsg = 'Invalid property name.';
        else
            errmsg = sprintf ('There is no field named %s.', propname);
        end
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function
