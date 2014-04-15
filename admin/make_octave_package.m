% MAKE_OCTAVE_PACKAGE

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@supelec.fr>

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

function make_octave_package ()

repo_dir  = fileparts (fileparts (mfilename ('fullpath')));

here = pwd ();

% From now on, we use relative paths wrt repo_dir
cd (repo_dir);

version_number = stk_version ()
pos = regexp (version_number, '[^\d\.]', 'once');
if ~ isempty (pos)
    original_version_number = version_number;
    version_number (pos:end) = [];
    warning (sprintf ('Truncating version numbers %s -> %s', ...
        original_version_number, version_number));
end

% Build dir
build_dir = 'octave-build'
mkdir (build_dir);

% Directory that will contain the unpacked octave package
package_dir = fullfile (build_dir, 'stk')
mkdir (package_dir);

% src: sources for MEX-files
mkdir (fullfile (package_dir, 'src'));

% doc: an optional directory containing documentation for the package
mkdir (fullfile (package_dir, 'doc'));

% List of files or directories that must be ignored by process_directory ()
ignore_list = {'.hg', 'admin', 'etc', 'misc/mole/matlab', build_dir};

% Prepare sed program for renaming MEX-functions (prefix/suffix by __)
sed_program = prepare_sed_rename_mex (repo_dir, build_dir);

% Process directories recursively
process_directory ('', package_dir, ignore_list, sed_program);

% Add mandatory file : DESCRIPTION
fid = fopen (fullfile (package_dir, 'DESCRIPTION'), 'wt');
fprintf (fid, 'Name: STK\n');
fprintf (fid, '#\n');
fprintf (fid, 'Version: %s\n', version_number);
fprintf (fid, '#\n');
fprintf (fid, 'Date: %s\n', date);
fprintf (fid, '#\n');
fprintf (fid, 'Title: STK: A Small Toolbox for Kriging\n');
fprintf (fid, '#\n');
fprintf (fid, 'Author: Julien BECT <julien.bect@supelec.fr>,\n');
fprintf (fid, ' Emmanuel VAZQUEZ <emmanuel.vazquez@supelec.fr>\n');
fprintf (fid, ' and many others (see AUTHORS)\n');
fprintf (fid, '#\n');
fprintf (fid, 'Maintainer: Julien BECT <julien.bect@supelec.fr>\n');
fprintf (fid, ' and Emmanuel VAZQUEZ <emmanuel.vazquez@supelec.fr>\n');
fprintf (fid, '#\n');
fprintf (fid, 'Description: blah blah blah\n');
fprintf (fid, '#\n');
fprintf (fid, 'Url: https://sourceforge.net/projects/kriging/\n');
fprintf (fid, '#\n');
fprintf (fid, 'Categories: Kriging\n');  % optional if an INDEX file is provided
fclose (fid);

% PKG_ADD: commands that are run when the package is added to the path
PKG_ADD = fullfile (package_dir, 'inst', 'PKG_ADD.m');
movefile (fullfile (package_dir, 'inst', 'stk_init.m'), PKG_ADD);
cmd = 'sed -i "s/STK_OCTAVE_PACKAGE = false/STK_OCTAVE_PACKAGE = true/" %s';
system (sprintf (cmd, PKG_ADD));

% PKG_DEL: commands that are run when the package is removed from the path
copyfile (fullfile ('etc', 'octave-pkg', 'PKG_DEL.m'), fullfile (package_dir, 'inst'));

% post_install: a function that is run after the installation of the package
copyfile (fullfile ('etc', 'octave-pkg', 'post_install.m'), package_dir);

% Makefile
copyfile (fullfile ('etc', 'octave-pkg', 'Makefile'), fullfile (package_dir, 'src'));

% Create tar.gz archive
cd (build_dir);
system (sprintf ('tar --create --gzip --file stk-%s.tar.gz stk', version_number));

cd (here)

end % function make_octave_package

%#ok<*NOPRT,*SPWRN,*WNTAG,*SPERR>


function process_directory (d, package_dir, ignore_list, sed_program)

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
            process_directory (s, package_dir, ignore_list, sed_program);
        else
            process_file (s, package_dir, sed_program);
        end
    end
end

end % function process_directory



function process_file (s, package_dir, sed_program)

% Regular expressions
regex_ignore = '(~|\.(hgignore|hgtags|mexglx|mex|o|tmp))$';
regex_mfile = '\.m$';
regex_copy_src = '\.[ch]$';

% FIXME/missing: CITATION

if ~ isempty (regexp (s, regex_ignore, 'once')) ...
        || strcmp (s, 'config/stk_config_buildmex.m') ...
        || strcmp (s, 'config/stk_config_makeinfo.m') ...
        || strcmp (s, 'misc/mole/README') ...
        || strcmp (s, 'misc/distrib/README') ...
        || strcmp (s, 'misc/optim/stk_optim_hasfmincon.m')
    
    fprintf ('Ignoring file %s\n', s);
    
else
    
    fprintf ('Processing file %s\n', s);
    
    if ~ isempty (regexp (s, regex_mfile, 'once'))
        
        dst = fullfile (package_dir, 'inst', s);
        mkdir_recurs (fileparts (dst));
        system (sprintf ('sed --file %s %s > %s', sed_program, s, dst));
        
    elseif ~ isempty (regexp (s, regex_copy_src, 'once'))
        
        copyfile (s, fullfile (package_dir, 'src'));
        
    elseif strcmp (s, 'ChangeLog')
        
        % DESCRIPTION, COPYING, ChangeLog & NEWS will be available
        % in "packinfo" after installation
        
        copyfile (s, package_dir);
        
    elseif strcmp (s, 'LICENSE')
        
        copyfile (s, fullfile (package_dir, 'COPYING'));
        
    elseif strcmp (s, 'WHATSNEW')
        
        copyfile (s, fullfile (package_dir, 'NEWS'));
        
    elseif (strcmp (s, 'README')) || (strcmp (s, 'AUTHORS'))
        
        % Put README and AUTHORS in the documentation directory
        copyfile (s, fullfile (package_dir, 'doc'));
        
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


function sed_program = prepare_sed_rename_mex (repo_dir, build_dir)

cd (fullfile (repo_dir, 'config'));
info = stk_config_makeinfo ();
cd (repo_dir);

sed_program = fullfile (build_dir, 'rename_mex.sed');
fid = fopen (sed_program, 'w');

for k = 1:(length (info))
    fprintf (fid, 's/%s/__%s__/g\n', info(k).mexname, info(k).mexname);
end

fclose (fid);

end % function rename_mex_functions
