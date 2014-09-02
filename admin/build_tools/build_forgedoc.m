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

function build_forgedoc (build_dir)

disp ('                                      ');
disp ('**************************************');
disp ('*  Build Octave-Forge documentation  *');
disp ('**************************************');
disp ('                                      ');

here = pwd ();

% Version number
version_number = get_version_number ();

% Name of the octpkg tarball
octpkg_tarball_name = sprintf ('stk-%s-octpkg.tar.gz', version_number);

% Install package
fprintf ('Installing stk %s (pkg install)... ', version_number);
cd (build_dir);
pkg ('install', octpkg_tarball_name);
fprintf ('done.\n');

% Generate HTML documentation
fprintf ('Generating HTML documentation for OF... ');
cd octpkg
pkg ('load', 'generate_html');
generate_package_html ('stk', 'html', 'octave-forge');
fprintf ('done.\n');

% Name of the forgedoc tarball
forgedoc_tarball_name = sprintf ('stk-%s-forgedoc.tar.gz', version_number);

% Create tar.gz archive
cd html
system (sprintf ('tar --create --gzip --file %s stk', forgedoc_tarball_name));
movefile (forgedoc_tarball_name, fullfile ('..', '..'));

% Download a few goodies from the Octave-Forge website
fprintf ('Downloading goodies from the OF website... ');
F = @(s) system (sprintf (...
    'wget --quiet http://octave.sourceforge.net/%s', s));
F ('octave-forge.css');  F ('download.png');  F ('doc.png');  F ('oct.png');
fprintf ('done.\n');

cd (here);

end % function make_octave_package

%#ok<*NOPRT,*SPWRN,*WNTAG,*SPERR,*AGROW>
