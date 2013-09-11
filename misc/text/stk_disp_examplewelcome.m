% STK_DISP_EXAMPLEWELCOME

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
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

function stk_disp_examplewelcome()

stack = dbstack();

if length(stack) >= 2,
    fprintf('%s\n', stk_sprintf_framed(stack(2).name));
else
    fprintf('This is a demo example...\n');
%     errmsg = 'stk_disp_examplewelcome() is meant to be used in example scripts.';
%     stk_error(errmsg, 'disp');
end



end % function stk_disp_examplewelcome
