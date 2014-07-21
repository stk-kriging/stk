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
config = fullfile (root, 'config');

% Add config to the path. It will be removed at the end of this script.
addpath (config);

% Activate the MOLE
stk_config_mole (root);

% Are we using STK installed as an octave package ?
STK_OCTAVE_PACKAGE = false;

% Build MEX-files "in-place" (unless STK is used as an Octave package)
if ~ STK_OCTAVE_PACKAGE
    stk_config_buildmex ();
    % To force recompilation of all MEX-files, use stk_config_buildmex (true);
end

% Add STK folders to the path (note: doing this ATFER building the MEX-files seems to
% solve the problem related to having MEX-files in private folders)
stk_config_addpath (root);

% Check that MEX-files located in private folders are properly detected (note:
% there are no MEX-files in private folders if STK is used as an Octave package)
if isoctave && (~ STK_OCTAVE_PACKAGE),
    stk_config_testprivatemex ();
end

% Configure STK with default settings
stk_config_setup;

% Uncomment this line if you want to see a lot of details about the internals
% of stk_dataframe and stk_factorialdesign objects:
% stk_options_set ('stk_dataframe', 'disp_format', 'verbose');

% Remove config from the path
rmpath (config);

clear root config STK_OCTAVE_PACKAGE ans;
