function make_octave_package ()

repo_dir  = fileparts (fileparts (mfilename ('fullpath')));

here = pwd ();

cd (fullfile (repo_dir, 'config'))
version_number = stk_version ()
pos = regexp ('2.2-dev', '[^\d\.]', 'once');
if ~ isempty (pos)
    original_version_number = version_number;
    version_number (pos:end) = [];
    warning (sprintf ('Truncating version numbers %s -> %s', ...
        original_version_number, version_number));
end
    
% From now on, we use relative paths wrt repo_dir
cd (repo_dir);

% Build dir
build_dir = 'octave-build'
mkdir (build_dir);

% Directory that will contain the unpacked octave package
package_dir = fullfile (build_dir, 'stk')
mkdir (package_dir);

% List of files or directories that must be ignored
ignore_list = {'.hg', 'admin', 'etc', 'misc/mole/matlab', build_dir};

% Process directories recursively
process_directory ('', package_dir, ignore_list)

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
fprintf (fid, 'Categories: Kriging\n');  % optional if an INDEX file is provided
fclose (fid);

% pre_install: a function that is run prior to the installation
copyfile (fullfile ('etc', 'octave-pkg', 'pre_install.m'), package_dir);

% PKG_ADD: commands that are run when the package is added to the path
copyfile (fullfile ('etc', 'octave-pkg', 'PKG_ADD.m'), fullfile (package_dir, 'PKG_ADD'));

% PKG_DEL: commands that are run when the package is removed from the path
copyfile (fullfile ('etc', 'octave-pkg', 'PKG_DEL.m'), fullfile (package_dir, 'PKG_DEL'));

% Create tar.gz archive
cd (build_dir);
system (sprintf ('tar --create --gzip --file stk-%s.tar.gz stk', version_number));

cd (here)

end % function make_octave_package



function process_directory (d, package_dir, ignore_list)

if ismember (d, ignore_list)
    fprintf ('Ignore directory %s\n', d);
    return;
else
    fprintf ('Process directory %s\n', d);
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
            process_directory (s, package_dir, ignore_list);
        else
            process_file (s, package_dir);
        end
    end
end

end % function process_directory



function process_file (s, package_dir)

fprintf ('Process file %s\n', s);

% Regular expressions
regex_copy_inst = '\.m$';
regex_copy_src = '\.[ch]$';

% FIXME/missing: CITATION

% Ignore some file extensions (just in case STK has been built in-place previously)
if isempty (regexp (s, '(~|\.(hgtags|mexglx|mex|o|tmp))$', 'once'))
    
    if ~ isempty (regexp (s, regex_copy_inst, 'once'))
        
        copy_to_dir (s, fileparts (fullfile (package_dir, 'inst', s)));
        
    elseif ~ isempty (regexp (s, regex_copy_src, 'once'))
        
        copy_to_dir (s, fileparts (fullfile (package_dir, 'src', s)));
        
    elseif strcmp (s, 'ChangeLog')
        
        % DESCRIPTION, COPYING, ChangeLog & NEWS will be available
        % in "packinfo" after installation
        
        copyfile (s, package_dir);
        
    elseif strcmp (s, 'LICENSE')
        
        copyfile (s, fullfile (package_dir, 'COPYING'));
        
    elseif strcmp (s, 'WHATSNEW')
        
        copyfile (s, fullfile (package_dir, 'NEWS'));
        
    elseif (strcmp (s, 'README')) || (strcmp (s, 'AUTHORS'))
        
        % README & AUTHORS: these two are placed at the root of the
        % package directory and will be moved to inst during install
        % (see pre_install.m)
        
        copyfile (s, package_dir);
        
    elseif ~ isempty (regexp (s, '/README$', 'once'))
        
        % other README files: copy directly to inst
        
        copy_to_dir (s, fileparts (fullfile (package_dir, 'inst', s)));
        
    else
        
        warning (sprintf ('Don''t know what to do with file %s', s));
        
    end
    
end % if

end % function process_file



function copy_to_dir (f, d)

mkdir_recurs (d);

copyfile (f, d);

end % function copy_to_dir



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
