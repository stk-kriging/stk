% STK_DISP_EXAMPLEWELCOME

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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
else
    demo_name = 'This is a demo example...';
end

fprintf ('\n%s\n', stk_sprintf_framed (demo_name));

help (demo_name);

end % function stk_disp_examplewelcome
