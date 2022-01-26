% BUILD_ALLPURPOSE

% Copyright Notice
%
%    Copyright (C) 2015-2017, 2020, 2022 CentraleSupelec
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

function build_allpurpose (root_dir, ...
    release_dir, octpkg_tarball, release_date)

disp ('                              ');
disp ('******************************');
disp ('*  Build allpurpose release  *');
disp ('******************************');
disp ('                              ');

here = pwd ();

% Create release_dir if necessary
if ~ exist (release_dir, 'dir')
    mkdir (release_dir);
end

% Directory that will contain the unpacked octave package
unpacked_dir = fullfile (release_dir, 'stk');
if exist (unpacked_dir, 'dir')
    rmdir (unpacked_dir, 's');
end
mkdir (unpacked_dir);

% Export files using 'git archive'
fprintf ('Exporting with "git archive" ... ');
cd (root_dir);
cmd = sprintf (['git archive --format=tar HEAD ' ...
		'| tar -x -C %s'], unpacked_dir);
assert (system (cmd) == 0);
fprintf ('done.\n\n');

% Instantiate CITATION template
cd (release_dir);
copy_citation ('stk/CITATION', 'stk', release_date);

% Write explicit version number in README.md
copy_readme ('stk/README.md', 'stk', release_date);

% Build HTML doc
htmldoc_dir = fullfile (unpacked_dir, 'doc', 'html');
build_allpurpose_htmldoc (root_dir, htmldoc_dir, octpkg_tarball);

fprintf ('done.\n');

cd (here);
