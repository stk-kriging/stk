% STK_INIT initializes the STK
%
% CALL: stk_init()
%
% STK_INIT sets paths and environment variables

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

%=== Turn output pagination OFF

more off

%=== Displaying the Copying Permission Statement

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

%=== Add STK folders to the path

STK_ROOT = fileparts (mfilename ('fullpath'));
addpath (fullfile (STK_ROOT, 'misc', 'config'));
addpath (fullfile (STK_ROOT, 'misc', 'mole', 'common'));
stk_set_root (STK_ROOT);

%=== Check which of Matlab or Octave is in use

if isoctave,
    fprintf ('Using Octave %s\n', OCTAVE_VERSION);
    % some Octave-specific configuration
    stk_octave_config;
else
    fprintf ('Using Matlab %s\n', version);
end

%=== Check for presence of the Parallel Computing Toolbox

fprintf ('Parallel Computing toolbox... ');
if isoctave,
    fprintf ('not available in Octave.\n');
else
    pct_found = stk_is_pct_installed;
    if pct_found,
        fprintf ('found.\n');
    else
        fprintf ('not found.\n');
    end
end

%=== Select optimizers for stk_param_estim

stk_select_optimizer;

%=== Build MEX-files (if necessary)

% to force recompilation of all MEX-files, use stk_compile_all(true);
stk_compile_all;

%=== Disable a warning in stk_predict

warning ('off', 'STK:stk_predict:NegativeVariancesSetToZero');

%=== Options

% Uncomment this line if you want to see a lot of details about the internals
% of stk_dataframe and stk_factorialdesign objects:
% stk_options_set ('stk_dataframe', 'disp_format', 'verbose');

%=== Cleanup

fprintf ('\n');

clear here STK_ROOT pct_found fmincon_found octave_in_use s ans

%=== Ways to get help, report bugs, ask for new features...

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
