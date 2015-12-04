% GET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function value = get (x, propname)

switch propname
    
    case 'lower_bounds'
        value = x.stk_dataframe.data(1, :);
        
    case 'upper_bounds'
        value = x.stk_dataframe.data(2, :);
        
    case 'stk_dataframe'  % Read-only access to the underlying df
        value = x.stk_dataframe;
        
    otherwise
        try
            value = get (x.stk_dataframe, propname);
        catch
            stk_error (sprintf ('There is no field named %s', propname), ...
                'InvalidArgument');
        end
end

end % function

%#ok<*CTCH>
