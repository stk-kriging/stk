% STK_RUNSCRIPT runs a script in a 'controlled' environment.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
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

function err = stk_runscript(scriptname)

has_dot_m = strcmp(scriptname(end-1:end), '.m');

if stk_is_octave_in_use(),
    % Octave's run() wants scriptnames WITH a .m in 3.6.2
    % (both forms were accepted in 3.2.4... damn it...)
    if ~has_dot_m,
        scriptname = [scriptname '.m'];
    end
else
    % Matlab wants scriptnames WITHOUT a .m
    if has_dot_m,
        scriptname = scriptname(1:end-2);
    end
end

err = [];

try
    run(scriptname);    
catch %#ok<CTCH>
    err = lasterror(); %#ok<LERR>
end

end % function stk_runscript
