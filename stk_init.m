% STK_INIT initializes the STK
%
% CALL: stk_init()
%
% STK_INIT sets paths and environment variables

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

% Deduce the root of STK from the path to this script
root = fileparts (mfilename ('fullpath'));

% Activate the MOLE (this needs to be done FIRST)
run (fullfile (root, 'misc', 'mole', 'PKG_ADD.m'));

% Turn output pagination OFF
pso_state = page_screen_output (0);

% Display the Copying Permission Statement
disp ('                                                                     ');
disp ('=====================================================================');
disp ('                                                                     ');
disp ('STK is free software: you can redistribute it and/or modify          ');
disp ('it under the terms of the GNU General Public License as published by ');
disp ('the Free Software Foundation, either version 3 of the License, or    ');
disp ('(at your option) any later version.                                  ');
disp ('                                                                     ');
disp ('STK is distributed in the hope that it will be useful,               ');
disp ('but WITHOUT ANY WARRANTY; without even the implied warranty of       ');
disp ('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ');
disp ('GNU General Public License for more details.                         ');
disp ('                                                                     ');
disp ('You should have received a copy of the GNU General Public License    ');
disp ('along with STK.  If not, see <http://www.gnu.org/licenses/>.         ');
disp ('                                                                     ');
disp ('=====================================================================');
disp ('                                                                     ');
fflush (stdout);

% Build MEX-files
if ~ (exist ('STK_SKIP_BUILDMEX', 'var') && STK_SKIP_BUILDMEX)
    stk_build (false, root, root);  % Build "in-place"
    % To force recompilation of all MEX-files, use stk_build (true, ...);
end

% Add STK folders to the path (note: doing this ATFER building the MEX-files seems to
% solve the problem related to having MEX-files in private folders)
addpath (fullfile (root, 'config'));  stk_config_addpath (root);  clear root;

% Check that MEX-files located in private folders are properly detected
if isoctave,  stk_config_testprivatemex ();  end

% Configure STK with default settings
stk_config_setup;

% Uncomment this line if you want to see a lot of details about the internals
% of stk_dataframe and stk_factorialdesign objects:
% stk_options_set ('stk_dataframe', 'disp_format', 'verbose');

% Ways to get help, report bugs, ask for new features...
disp ('                                                                     ');
disp ('=====================================================================');
disp ('                                                                     ');
disp ('Use the "help" mailing-list:                                         ');
disp ('                                                                     ');
disp ('   kriging-help@lists.sourceforge.net                                ');
disp ('   https://sourceforge.net/p/kriging/mailman                         ');
disp ('                                                                     ');
disp ('to ask for help on STK, and the ticket manager:                      ');
disp ('                                                                     ');
disp ('   https://sourceforge.net/p/kriging/tickets                         ');
disp ('                                                                     ');
disp ('to report bugs or ask for new features.                              ');
disp ('                                                                     ');
disp ('=====================================================================');
disp ('                                                                     ');
fflush (stdout);

% Restore PSO state
page_screen_output (pso_state);  clear pso_state ans;
