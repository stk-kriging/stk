% BUILD_ALLPURPOSE

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

function build_allpurpose (root_dir, build_dir)

disp ('                              ');
disp ('******************************');
disp ('*  Build allpurpose release  *');
disp ('******************************');
disp ('                              ');

here = pwd ();

% Directory: allpurpose
allpurpose_dir = fullfile (build_dir, 'allpurpose');
if exist (allpurpose_dir, 'dir')
    rmdir (allpurpose_dir, 's');
end
mkdir (allpurpose_dir);

% Directory that will contain the unpacked octave package
unpacked_dir = fullfile (allpurpose_dir, 'stk');
mkdir (unpacked_dir);

% Version number
version_number = get_version_number ();

% Tarball name
tarball_name = sprintf ('stk-%s-allpurpose.tar.gz', version_number);
fprintf ('Tarball name: %s\n', tarball_name);

% Export files using 'hg archive'
fprintf ('Exporting with "hg archive" ... ');
cd (root_dir);
system (sprintf ('hg archive %s', unpacked_dir));
fprintf ('done.\n');

% Delete admin dir
fprintf ('Deleting admin dir ... ');
tmp = confirm_recursive_rmdir (0);
rmdir (fullfile (unpacked_dir, 'admin'), 's');
confirm_recursive_rmdir (tmp);
fprintf ('done.\n');

% Instantiate CITATION template
cd (allpurpose_dir);
copy_citation ('stk/CITATION', 'stk');

% Write explicit version number in README
copy_readme ('stk/README', 'stk');

% Build HTML doc
htmldoc_dir = fullfile (allpurpose_dir, 'stk', 'doc', 'html');
build_allpurpose_htmldoc (root_dir, build_dir, htmldoc_dir, version_number);

% Create tarball
fprintf ('Creating tarball: %s ... ', tarball_name);
system (sprintf ('tar --create --gzip --file %s %s', tarball_name, 'stk'));
movefile (tarball_name, '..');
fprintf ('done.\n');

cd (here);