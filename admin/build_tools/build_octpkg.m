% BUILD_OCTAVE_PACKAGE

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
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

function build_octpkg (root_dir, release_dir)

disp ('                          ');
disp ('**************************');
disp ('*  Build octave package  *');
disp ('**************************');
disp ('                          ');

here = pwd ();

% From now on, we use relative paths wrt root_dir
cd (root_dir);

% A directory that contains various files,
% which are used to create the package
pkg_bits_dir = fullfile ('admin', 'octpkg');

% Get a valid version number (without an extension such as '-dev')
version_number = get_version_number ();

% Create release_dir if necessaryrelease_dir
if ~ exist (release_dir, 'dir')
    mkdir (release_dir);
end

% Directory that will contain the unpacked octave package
unpacked_dir = fullfile (release_dir, 'stk');
if exist (unpacked_dir, 'dir')
    rmdir (unpacked_dir, 's');
end
mkdir (unpacked_dir);

% src: sources for MEX-files
mkdir (fullfile (unpacked_dir, 'src'));

% doc: an optional directory containing documentation for the package
mkdir (fullfile (unpacked_dir, 'doc'));

% List of directories that must be ignored by process_directory ()
ignore_list = {'.hg', 'admin', 'misc/mole/matlab', 'build'};

% Prepare sed program for renaming MEX-functions (prefix/suffix by __)
sed_program = prepare_sed_rename_mex (root_dir, release_dir);

% Process directories recursively
process_directory ('', unpacked_dir, ignore_list, sed_program);

% Cleanup: delete sed program
delete (sed_program);

% Add mandatory file : DESCRIPTION
fid = fopen_ (fullfile (unpacked_dir, 'DESCRIPTION'), 'wt');
fprintf (fid, 'Name: STK\n');
fprintf (fid, '#\n');
fprintf (fid, 'Version: %s\n', version_number);
fprintf (fid, '#\n');
fprintf (fid, 'Date: %s\n', date);
fprintf (fid, '#\n');
fprintf (fid, 'Title: STK: A Small Toolbox for Kriging\n');
fprintf (fid, '#\n');
fprintf (fid, 'Author: See AUTHORS file\n');
fprintf (fid, '#\n');
fprintf (fid, 'Maintainer: Julien BECT <julien.bect@supelec.fr>\n');
fprintf (fid, ' and Emmanuel VAZQUEZ <emmanuel.vazquez@supelec.fr>\n');
fprintf (fid, '#\n');
fprintf (fid, '%s', parse_description_field (root_dir));
fprintf (fid, '#\n');
fprintf (fid, 'Url: https://sourceforge.net/projects/kriging/\n');
fclose (fid);

% PKG_ADD: commands that are run when the package is added to the path
PKG_ADD = fullfile (unpacked_dir, 'inst', 'PKG_ADD.m');
movefile (fullfile (unpacked_dir, 'inst', 'stk_init.m'), PKG_ADD);
cmd = 'sed -i "s/STK_OCTAVE_PACKAGE = false/STK_OCTAVE_PACKAGE = true/" %s';
system (sprintf (cmd, PKG_ADD));

% PKG_DEL: commands that are run when the package is removed from the path
copyfile (fullfile (pkg_bits_dir, 'PKG_DEL.m'), ...
    fullfile (unpacked_dir, 'inst'));

% post_install: a function that is run after the installation of the package
copyfile (fullfile (pkg_bits_dir, 'post_install.m'), unpacked_dir);

% Makefile
copyfile (fullfile (pkg_bits_dir, 'Makefile'), ...
    fullfile (unpacked_dir, 'src'));

% INDEX
index_file = fullfile (pkg_bits_dir, 'INDEX');
check_index_file (index_file, ...
    get_public_mfile_list (fullfile (unpacked_dir, 'inst')));
copyfile (index_file, unpacked_dir);

cd (here)

end % function make_octave_package

%#ok<*NOPRT,*SPWRN,*WNTAG,*SPERR,*AGROW>


function process_directory (d, unpacked_dir, ignore_list, sed_program)

if ismember (d, ignore_list)
    fprintf ('Ignoring directory %s\n', d);
    return;
else
    fprintf ('Processing directory %s\n', d);
end

if isempty (d)
    dir_content = dir ();
else
    dir_content = dir (d);
end

for i = 1:(length (dir_content))
    s = dir_content(i).name;
    if ~ (isequal (s, '.') || isequal (s, '..'))
        s = fullfile (d, s);
        if dir_content(i).isdir
            process_directory (s, unpacked_dir, ignore_list, sed_program);
        else
            process_file (s, unpacked_dir, sed_program);
        end
    end
end

end % function process_directory



function process_file (s, unpacked_dir, sed_program)

% Regular expressions
regex_ignore = '(~|\.(hgignore|hgtags|mexglx|mex|mexa64|mexw64|o|tmp|orig))$';
regex_mfile = '\.m$';
regex_copy_src = '\.[ch]$';

if ~ isempty (regexp (s, regex_ignore, 'once')) ...
        || strcmp (s, 'Makefile') ...
        || strcmp (s, 'config/stk_config_buildmex.m') ...
        || strcmp (s, 'config/stk_config_makeinfo.m') ...
        || strcmp (s, 'misc/mole/README') ...
        || strcmp (s, 'misc/distrib/README') ...
        || strcmp (s, 'misc/test/stk_test.m') ...
        || strcmp (s, 'misc/test/stk_runtests.m') ...
        || strcmp (s, 'misc/optim/stk_optim_hasfmincon.m') ...
        || strcmp (s, 'doc/dev/model.texi')
    
    fprintf ('Ignoring file %s\n', s);
    
else
    
    fprintf ('Processing file %s\n', s);
    
    if ~ isempty (regexp (s, regex_mfile, 'once'))
        
        dst = fullfile (unpacked_dir, 'inst', s);
        mkdir_recurs (fileparts (dst));
        system (sprintf ('sed --file %s %s > %s', sed_program, s, dst));
        
    elseif ~ isempty (regexp (s, regex_copy_src, 'once'))
        
        copyfile (s, fullfile (unpacked_dir, 'src'));
        
    elseif any (strcmp (s, {'ChangeLog' 'NEWS' 'COPYING'}))
        
        % DESCRIPTION, COPYING, ChangeLog & NEWS will be available
        % in "packinfo" after installation
        
        copyfile (s, unpacked_dir);
        
    elseif strcmp (s, 'AUTHORS')
        
        % Put AUTHORS in the documentation directory
        copyfile (s, fullfile (unpacked_dir, 'doc'));
        
    elseif strcmp (s, 'README')
        
        % Put README in the documentation directory
        copy_readme (s, fullfile (unpacked_dir, 'doc'));
        
    elseif strcmp (s, 'CITATION')
        
        copy_citation (s, unpacked_dir);
        
    else
        
        error (sprintf ('Don''t know what to do with file %s', s));
        
    end
    
end % if

end % function process_file


function mkdir_recurs (d)

if ~ exist (d, 'dir')
    
    d0 = fileparts (d);
    
    if (~ isempty (d0)) && (~ exist (d0, 'dir'))
        mkdir_recurs (d0);
    end
    
    if ~ exist (d, 'dir')
        mkdir (d);
    end
    
end

end % function mkdir_recurs


function sed_program = prepare_sed_rename_mex (root_dir, release_dir)

cd (fullfile (root_dir, 'config'));
info = stk_config_makeinfo ();
cd (root_dir);

sed_program = fullfile (release_dir, 'rename_mex.sed');
fid = fopen_ (sed_program, 'w');

for k = 1:(length (info))
    fprintf (fid, 's/%s/__%s__/g\n', info(k).mexname, info(k).mexname);
end

fclose (fid);

end % function prepare_sed_rename_mex


function descr = parse_description_field (root_dir)

fid = fopen_ (fullfile (root_dir, 'README'), 'rt');

s = [];

%--- Step 1: find first description line ---------------------------------

while 1,
    
    L = fgetl (fid);
    if ~ ischar (L),
        error ('Corrupted README file ?');
    end
    
    L = strtrim (L);
    idx = strfind (L, 'Description:');
    if (~ isempty (idx)) && (idx(1) == 1)
        s = L;
        break;
    end
    
end

%--- Step 2: get other description lines ---------------------------------

while 1,
    
    L = fgetl (fid);
    if ~ ischar (L),
        error ('Corrupted README file ?');
    end
    
    L = strtrim (L);
    if isempty (L),  break;  end
    s = [s ' ' L];
    
end

fclose (fid);

%--- Step 3: line wrapping -----------------------------------------------

max_length = 75;
descr = [];

while 1,
    
    % last line
    if length (s) <= max_length,
        descr = [descr sprintf(' %s\n', s)];
        break;
    end
    
    i = find (s == ' ');
    j = find (i <= max_length + 1, 1, 'last');
    i = i(j);
    if isempty (descr),
        descr = sprintf ('%s\n', s(1:(i - 1)));
    else
        descr = [descr sprintf(' %s\n', s(1:(i - 1)))];
    end
    s = s((i + 1):end);
    
end

end
