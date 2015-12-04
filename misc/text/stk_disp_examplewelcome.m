% STK_DISP_EXAMPLEWELCOME

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function stk_disp_examplewelcome ()

stack = dbstack ();

if length(stack) >= 2,
    demo_name = stack(2).name;
    display_help = true;
else
    demo_name = 'This is a demo example...';
    display_help = false;
end

fprintf ('\n%s\n', stk_sprintf_framed (demo_name));

if display_help
    help (demo_name);
end

end % function
