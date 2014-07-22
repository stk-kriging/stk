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
        
        dst = fullfile (unpacked_dir, 'inst', s);
        mkdir_recurs (fileparts (dst));
        system (sprintf ('sed --file %s %s > %s', sed_program, s, dst));
        
    elseif ~ isempty (regexp (s, regex_copy_src, 'once'))
        
        copyfile (s, fullfile (unpacked_dir, 'src'));
        
    elseif any (strcmp (s, {'ChangeLog' 'NEWS'}))
        
        % DESCRIPTION, COPYING, ChangeLog & NEWS will be available
        % in "packinfo" after installation
        
        copyfile (s, unpacked_dir);
        
    elseif strcmp (s, 'LICENSE')
        
        copyfile (s, fullfile (unpacked_dir, 'COPYING'));
        
    elseif (strcmp (s, 'README')) || (strcmp (s, 'AUTHORS'))
        
        % Put README and AUTHORS in the documentation directory
        copyfile (s, fullfile (unpacked_dir, 'doc'));
        
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


function sed_program = prepare_sed_rename_mex (root_dir, build_dir)

cd (fullfile (root_dir, 'config'));
info = stk_config_makeinfo ();
cd (root_dir);

sed_program = fullfile (build_dir, 'rename_mex.sed');
fid = fopen (sed_program, 'w');

for k = 1:(length (info))
    fprintf (fid, 's/%s/__%s__/g\n', info(k).mexname, info(k).mexname);
end

fclose (fid);

end % function rename_mex_functions


function descr = parse_description_field (root_dir)

fid = fopen (fullfile (root_dir, 'README'));

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
