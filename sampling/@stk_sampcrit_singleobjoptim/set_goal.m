% SET_GOAL ...

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

function crit = set_goal (crit, goal)

if strcmp (goal, 'minimize')
    
    crit.goal = 'minimize';
    crit.bminimize = true;
    
elseif strcmp (goal, 'maximize')
    
    crit.goal = 'maximize';
    crit.bminimize = false;
    
elseif ischar (goal)  % Correct type but incorrect value
    
    stk_error (sprintf (['Incorrect value for property ''goal'': ' ...
        '%s.\nThe value should be either ''minimize'' or ' ...
        '''maximize''.'], goal), 'IncorrectValue');
    
else  % Incorrect type
    
    stk_error (sprintf (['Incorrect value type for property ''goal'': ' ...
        '%s.\nThe value should a character string (char).'], ...
        class (goal)), 'TypeMismatch');
    
end % if

end % function
