% BUILD

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function build (target)
  
here = pwd ();

if nargin == 0,
    target = 'all';
end

% Directories
admin_dir = fileparts (mfilename ('fullpath'));
root_dir  = fileparts (admin_dir);

% Addpaths
addpath (root_dir);  % contains stk_version ()
addpath (fullfile (admin_dir, 'build_tools'));

% Build dir
build_dir = fullfile (root_dir, 'build');
if ~ exist (build_dir, 'dir')
    mkdir (build_dir);
elseif strcmp (target, 'all')
    rmdir (build_dir, 's');
    mkdir (build_dir);
end

% Build target
try
    switch target
    
        case 'allpurpose'
            build_allpurpose (root_dir, build_dir);
            
        case 'octpkg'
            build_octpkg (root_dir, build_dir);
            
        case 'forgedoc'                    
            if (exist ('OCTAVE_VERSION', 'builtin') == 5)
                build_forgedoc (root_dir, build_dir);
            else
                error ('Cannot build forgedoc from Matlab.');
            end
            
        case 'all'
            build octpkg;
            build forgedoc;
            build allpurpose;
            
        otherwise
            error ('Unknowwn target');
    end
catch
    cd (here)
    rethrow (lasterror ());
end

cd (here)

end % function build
