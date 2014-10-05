% BUILD_FORGEDOC

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

function build_forgedoc (root_dir, build_dir)

disp ('                                      ');
disp ('**************************************');
disp ('*  Build Octave-Forge documentation  *');
disp ('**************************************');
disp ('                                      ');

here = pwd ();

% Version number
version_number = get_version_number ();

% Where we want the documentation to be generated (unpacked)
htmldoc_dir = fullfile (build_dir, 'octpkg', 'html', 'stk');

% Generate the documentation
generate_htmldoc (root_dir, build_dir, ...
    htmldoc_dir, version_number, 'forgedoc');

% Name of the forgedoc tarball
forgedoc_tarball_name = sprintf ('stk-%s-forgedoc.tar.gz', version_number);

% Create tar.gz archive
cd (fileparts (htmldoc_dir));
system (sprintf ('tar --create --gzip --file %s stk', forgedoc_tarball_name));
movefile (forgedoc_tarball_name, fullfile ('..', '..'));

% Download a few goodies from the Octave-Forge website
fprintf ('Downloading goodies from the OF website...\n');
F = @(s) system (sprintf (...
    'wget --quiet http://octave.sourceforge.net/%s', s));
F ('octave-forge.css');  F ('download.png');  F ('doc.png');  F ('oct.png');

fprintf ('Done.\n');  cd (here);

end % function make_octave_package
