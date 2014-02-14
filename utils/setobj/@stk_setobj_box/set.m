% SET [overloaded base function]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function x = set (x, propname, value)

switch propname
    
    case 'lb'
        
        if iscolumn (value),
            value = value';
        end
        
        if ~ isequal (size (value), size (x.lb))
            
            stk_error (sprintf (['The value of property ''lb'' should be a vector ' ...
                'of length d = %d'], size (x.lb, 2)), 'IncorrectSize');
            
        elseif any (value > x.ub)
            
            errmsg = 'Lower bounds cannot be greater than upper bounds !';
            stk_error (errmsg, 'InvalidArgument');
            
        else
            
            x.lb = value;
            
        end
        
    case 'ub'
        
        if iscolumn (value),
            value = value';
        end
        
        if ~ isequal (size (value), size (x.ub))
            
            stk_error (sprintf (['The value of property ''ub'' should be a vector ' ...
                'of length d = %d'], size (x.ub, 2)));
            
        elseif any (value < x.lb)
            
            errmsg = 'Upper bounds cannot be smaller than lower bounds !';
            stk_error (errmsg, 'InvalidArgument');

        else
            
            x.ub = value;
            
        end
        
    case 'dim'
        errmsg = sprintf ('Property: %s is read-only.', propnam);
        stk_error (errmsg, 'ReadOnlyProperty');
        
    otherwise
        errmsg = sprintf ('Unknown property: %s', propnam);
        stk_error (errmsg, 'UnknownProperty');
        
end

end % function set
