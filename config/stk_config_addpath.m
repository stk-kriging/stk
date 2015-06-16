% STK_CONFIG_ADDTOPATH adds STK subfolders to the search path

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
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

function stk_config_addpath (root)

while 1,  % Remove other copies of STK from the search path
    
    [current_root, found_in_path] = stk_config_getroot ();
    if (~ found_in_path) || (strcmp (current_root, root))
        break;
    end
    
    warning (sprintf (['Removing another copy of STK from the ' ...
        'search path.\n    (%s)\n'], current_root));
    
    stk_config_rmpath (current_root);
    
end

% Add STK folders to the path
path = stk_config_path (root);
for i = 1:length (path),
    if exist (path{i}, 'dir')
        addpath (path{i});
    else
        error (sprintf (['Directory %s does not exist.\n' ...
            'Is there a problem in stk_config_path ?'], path{i}));
    end
end

% Selectively add MOLE subdirectories to compensate for missing functions
% (note that stk_init.m also does that, but it is necessary to do it again here,
% just in case some functions were provided by another copy of STK that has been removed
% from the path by stk_config_addpath (see above))
stk_config_mole (root);

end % function stk_config_addpath

%#ok<*NODEF,*WNTAG,*SPERR,*SPWRN>
