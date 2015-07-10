% STK_CONFIG_BUILDMEX compiles all MEX-files in the STK

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
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

function stk_config_buildmex (force_recompile)

if nargin < 1,
    force_recompile = false;
end

root = fileparts (fileparts (mfilename ('fullpath')));

here = pwd ();

opts.force_recompile = force_recompile;
opts.include_dir = fullfile (root, 'misc', 'include');

info = stk_config_makeinfo ();

for k = 1:(length (info)),
    stk_compile (fullfile (root, info(k).relpath), ...
        opts, info(k).mexname, info(k).other_src, info(k).includes);
end

cd (here);

end % function stk_config_buildmex

%#ok<*SPERR>


function stk_compile (d, opts, mexname, other_src, includes)

mex_filename = [mexname '.' mexext];
mex_fullpath = fullfile (d, mex_filename);

src_filename = [mexname '.c'];

dir_mex = dir (mex_fullpath);
compile = opts.force_recompile || (isempty (dir_mex));

src_files = [{src_filename} other_src];

for k = 1:(length (src_files))
    % Look for src file in current directory
    dir_src = dir (fullfile (d, src_files{k}));
    if isempty (dir_src)
        error ('STK:stk_config_buildmex:FileNotFound', ...
            sprintf ('Source file %s not found', src_files{k}));
    end
    compile = compile || (dir_mex.datenum < dir_src.datenum);
end

if ~ isempty (includes)
    for k = 1:(length (includes))        
        % Look for header file in current directory
        dir_hdr = dir (fullfile (d, includes{k}));
        if isempty (dir_hdr)
            % Look for header file in include directory
            dir_hdr = dir (fullfile (opts.include_dir, includes{k}));
            if isempty (dir_hdr)
                error ('STK:stk_config_buildmex:FileNotFound', ...
                    sprintf ('Header file %s not found', includes{k}));
            end
        end
        compile = compile || (dir_mex.datenum < dir_hdr.datenum);
    end
end

if compile,
    
    fprintf ('[stk_config_buildmex] Compiling MEX-file %s... ', mexname);
    
    cd (d);
    
    include = sprintf ('-I%s', opts.include_dir);
    mex (src_files{:}, include);
    
    if ~ strcmp (d, d)
        if ~ exist (d, 'dir')
            mkdir (d);
        end
        movefile (fullfile (d, mex_filename), d);
    end
    
    fprintf ('ok.\n');  fflush (stdout);
    
end

end % function stk_compile
