% STK_PATH returns the searchpath of STK.
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

function path = stk_path (root)

if nargin == 0,
    root = stk_get_root ();
end

% main function folders
path = { ...
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
    fullfile(misc, 'config'  ) ...
    fullfile(misc, 'design'  ) ...
    fullfile(misc, 'dist'    ) ...
    fullfile(misc, 'distrib' ) ...    
    fullfile(misc, 'error'   ) ...
    fullfile(misc, 'options' ) ...
    fullfile(misc, 'parallel') ...    
    fullfile(misc, 'plot'    ) ...
    fullfile(misc, 'specfun' ) ...
    fullfile(misc, 'stats'   ) ...
    fullfile(misc, 'test'    ) ...
    fullfile(misc, 'text'    ) }];

% folders that contain examples
path = [path {...
    fullfile(root, 'examples', '01_kriging_basics'       ) ...
    fullfile(root, 'examples', '02_design_of_experiments') ...
    fullfile(root, 'examples', '03_miscellaneous'        ) ...
    fullfile(root, 'examples', 'test_functions'          ) }];

% MOLE: Matlab/Octave common part
path = [path {fullfile(misc, 'mole', 'common')}];

if ~isoctave,
    % MOLE: Matlab-specific part
    path = [path {fullfile(misc, 'mole', 'matlab')}];
else
    % MOLE: Octave-specific part
    path = [path {fullfile(misc, 'mole', 'octave')}];
end

end % function stk_path
