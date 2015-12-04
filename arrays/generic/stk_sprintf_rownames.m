% STK_SPRINTF_ROWNAMES returns the row names of an array

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function s = stk_sprintf_rownames (x)

if ~ isnumeric (x)
    
    errmsg = sprintf ('Incorrect argument type: %s', class (x));
    stk_error (errmsg, 'IncorrectType');
    
else
    
    n = size (x, 1);
    if n == 1
        s = sprintf ('{} (unnamed row)');
    else
        s = sprintf ('{} (unnamed rows)');
    end
    
end

end % function
