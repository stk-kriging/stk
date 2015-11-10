% STK_INIT initializes the STK
%
% CALL: stk_init()
%
% STK_INIT sets paths and environment variables

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
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

%% PKG_ADD: stk_init ();

%% PKG_DEL: stk_init (true);

function stk_init (do_quit)

% Deduce the root of STK from the path to this script
root = fileparts (mfilename ('fullpath'));
config = fullfile (root, 'config');

% Add config to the path. It will be removed at the end of this script.
addpath (config);

% Unlock all possibly mlock-ed STK files and clear all STK functions
% that contain persistent variables
stk_config_clearpersistents ();

if (nargin > 0) && (do_quit)

    % Remove STK subdirectories from the path
    stk_config_rmpath (root);

    % No need to remove config manually at the end of the script since
    % it is removed by stk_config_rmpath. We can exit.
    return

end

% Activate the MOLE
stk_config_mole (root);

% Build MEX-files "in-place"
stk_config_buildmex ();

% Add STK folders to the path (note: doing this ATFER building the MEX-files
% seems to solve the problem related to having MEX-files in private folders)
stk_config_addpath (root);

% Check that MEX-files located in private folders are properly detected (note:
% there are no MEX-files in private folders if STK is used as an Octave package)
if isoctave
    stk_config_testprivatemex ();
end

% Configure STK with default settings
stk_config_setup;

% Uncomment this line if you want to see a lot of details about the internals
% of stk_dataframe and stk_factorialdesign objects:
% stk_options_set ('stk_dataframe', 'disp_format', 'verbose');

% Remove config from the path
rmpath (config);

end % function stk_init
