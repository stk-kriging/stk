% BUILD

% Copyright Notice
%
%    Copyright (C) 2015, 2022 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function build (target, varargin)
  
% Directories
admin_dir = fileparts (mfilename ('fullpath'));
root_dir  = fileparts (admin_dir);

% Add build tools to the path
addpath (fullfile (admin_dir, 'build_tools'));

% Build target
switch target

    case 'vernum'
        fid = fopen (varargin{1}, 'wt');
        fprintf (fid, '%s', get_version_number ());
        fclose (fid);

    case 'allpurpose'
        build_allpurpose (root_dir, varargin{:});

    case 'octpkg'
        build_octpkg (root_dir, varargin{:});

    case 'forgedoc'
        generate_htmldoc (root_dir, varargin{:}, 'forgedoc');

    otherwise
        error ('Unknown target');
end

end % function
