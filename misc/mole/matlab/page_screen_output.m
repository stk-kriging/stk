% PAGE_SCREEN_OUTPUT controls the state of the pager

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@supelec.fr>

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

function old_val = page_screen_output (new_val)

switch get (0, 'More')
    case 'on',
        old_val = 1;
    case 'off',
        old_val = 0;
    otherwise
        error ('Unexpected value returned by get (0, ''More'').');
end

if nargin > 0,
    if new_val,
        more on;
    else
        more off;
    end
end
        
end % function page_screen_output
