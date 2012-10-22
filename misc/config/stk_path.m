% STK_PATH returns the searchpath of STK.
%
% FIXME: missing doc
%

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
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

function path = stk_path(root)

if nargin == 0,
    root = stk_get_root();
end

% folders that contain functions
path = { ...
    fullfile(root, 'core'            ) ...
    fullfile(root, 'covfcs'          ) ...
    fullfile(root, 'paramestim'      ) ...
    fullfile(root, 'sampling'        ) ...
    fullfile(root, 'utils'           ) ...
    fullfile(root, 'misc'            ) ...
    fullfile(root, 'misc', 'config'  ) ...
    fullfile(root, 'misc', 'dist'    ) ...
    fullfile(root, 'misc', 'disp'    ) ...    
    fullfile(root, 'misc', 'error'   ) ...
    fullfile(root, 'misc', 'plot'    ) ...
    fullfile(root, 'misc', 'specfun' ) ...
    fullfile(root, 'misc', 'test'    ) };
    
% folders that contain examples
path = { path{:} ...
    fullfile(root, 'examples', '01_kriging_basics'       ) ...
    fullfile(root, 'examples', '02_design_of_experiments') ...
    fullfile(root, 'examples', '03_miscellaneous'        ) };

if ~stk_is_octave_in_use(),
    path = [path {fullfile(root, 'misc', 'matlab')}];
end

end % stk_path
