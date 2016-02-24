% DISP [overload base function]

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function disp (crit)

loose_spacing = strcmp (get (0, 'FormatSpacing'), 'loose');

fprintf ('<%s>\n', stk_sprintf_sizetype (crit));

if loose_spacing
    fprintf ('\n');
end

if ~ strcmp (class (crit), 'stk_sampcrit_base')
    
    fprintf ('*** WARNING: %s has no proper disp () method.\n', class (crit));
    
    if loose_spacing
        fprintf ('***\n');
    end
    
    fprintf ('*** Dumping the raw content of the underlying structure...\n');
    
    if loose_spacing
        fprintf ('***\n\n');
    end
    
    disp (struct(crit));
    
    if loose_spacing
        fprintf ('\n');
    end
    
end % if

end % function
