% STK_CONFIG_PATH returns the searchpath of STK
%
% FIXME: missing doc
%

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Author:   Julien Bect  <julien.bect@supelec.fr>

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

% main function folders
path = {...
    fullfile(root, 'config'                     ) ...
    fullfile(root, 'core'                       ) ...
    fullfile(root, 'covfcs'                     ) ...
    fullfile(root, 'paramestim'                 ) ...
    fullfile(root, 'sampling'                   ) ...
    fullfile(root, 'utils'                      ) ...
    fullfile(root, 'utils', 'arrays'            ) ...
    fullfile(root, 'utils', 'arrays', 'generic' ) };

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
    fullfile(misc, 'plot'    ) ...
    fullfile(misc, 'specfun' ) ...
    fullfile(misc, 'test'    ) ...
    fullfile(misc, 'text'    ) }];

% folders that contain examples
path = [path {...
    fullfile(root, 'examples', '01_kriging_basics'       ) ...
    fullfile(root, 'examples', '02_design_of_experiments') ...
    fullfile(root, 'examples', '03_miscellaneous'        ) ...
    fullfile(root, 'examples', 'test_functions'          ) }];

mole_dir = fullfile (misc, 'mole');

% MOLE: Matlab/Octave common part
path = [path {fullfile(mole_dir, 'common')}];

if ~ isoctave,  % MOLE: Matlab-specific part
    
    path = [path {fullfile(mole_dir, 'matlab')}];
    
    % replacement functions for people that do not have the Statistics toolbox
    if isempty (ver ('stats'))
        path = [path {...
            fullfile(mole_dir, 'corr')     ...
            fullfile(mole_dir, 'quantile') }];
    end
    
else  % MOLE: Octave-specific part
    
    % corr is missing in Octave 3.2.4 (when was it added ?)
    if ~ exist ('corr', 'file')
        path = [path {fullfile(mole_dir, 'corr')}];
    end
    
    % linsolve is missing in Octave, up to 3.6.4
    if ~ exist ('linsolve', 'file')
        path = [path {fullfile(mole_dir, 'linsolve')}];
    end
    
end

% Fix a problem with private folders in Octave 3.2.x
if isoctave,
    v = version;
    if strcmp (v(1:4), '3.2.')
        path = [path {...
            fullfile(root, 'utils', 'arrays', '@stk_dataframe', 'private') ...
            fullfile(root, 'misc', 'dist', 'private')}];
    end
end

end % function stk_config_path
