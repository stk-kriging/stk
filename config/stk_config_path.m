% STK_CONFIG_PATH returns the searchpath of STK

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
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

function path = stk_config_path (root)

if nargin == 0,
    root = stk_config_getroot ();
end

% Safer than calling isoctave directly (this allows stk_config_path to work
% even if STK has already been partially uninstalled or is not properly installed)
isoctave = (exist ('OCTAVE_VERSION', 'builtin') == 5);

path = {root};

% main function folders
path = [path {...
    fullfile(root, 'arrays'            ) ...
    fullfile(root, 'arrays', 'generic' ) ...
    fullfile(root, 'core'              ) ...
    fullfile(root, 'covfcs'            ) ...
    fullfile(root, 'lm'                ) ...
    fullfile(root, 'paramestim'        ) ...
    fullfile(root, 'sampling'          ) ...
    fullfile(root, 'utils'             ) }];

% 'misc' folder and its subfolders
misc = fullfile (root, 'misc');
path = [path {...
    fullfile(misc, 'design'  ) ...
    fullfile(misc, 'dist'    ) ...
    fullfile(misc, 'distrib' ) ...
    fullfile(misc, 'error'   ) ...
    fullfile(misc, 'optim'   ) ...
    fullfile(misc, 'options' ) ...
    fullfile(misc, 'parallel') ...
    fullfile(misc, 'pareto'  ) ...    
    fullfile(misc, 'plot'    ) ...
    fullfile(misc, 'specfun' ) ...
    fullfile(misc, 'test'    ) ...
    fullfile(misc, 'text'    ) }];

% IAGO
iago = fullfile (root, 'iago');
path = [path {iago ...
    fullfile(iago, 'crit'   ) ...
    fullfile(iago, 'rep'    ) ...
    fullfile(iago, 'utils'  ) ...
    fullfile(iago, 'viewfcs')}];

% folders that contain examples
path = [path {...
    fullfile(root, 'examples', '01_kriging_basics'       ) ...
    fullfile(root, 'examples', '02_design_of_experiments') ...
    fullfile(root, 'examples', '03_miscellaneous'        ) ...
    fullfile(root, 'examples', 'test_functions'          ) }];

% Fix a problem with private folders in Octave 3.2.x
%   (add private folders to the path to make STK work...)
if isoctave
    v = version;
    if strcmp (v(1:4), '3.2.')
        test_path = [path {...
            fullfile(root, 'arrays', '@stk_dataframe') ...
            fullfile(root, 'arrays', '@stk_factorialdesign') ...
            fullfile(root, 'core', '@stk_kreq_qr')}];
        private_path = {};
        for i = 1:(length (test_path))
            p = fullfile (test_path{i}, 'private');
            if exist (p, 'dir')
                private_path = [private_path {p}];
            end
        end
        path = [path private_path];
    end
end

end % function stk_config_path
