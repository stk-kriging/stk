% STK_CONFIG_BUILDMEX compiles all MEX-files in the STK

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
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
        opts, info(k).mexname, info(k).includes);
end

cd (here);

end % function stk_config_buildmex

%#ok<*SPERR>


function stk_compile (d, opts, mexname, includes)

mex_filename = [mexname '.' mexext];
mex_fullpath = fullfile (d, mex_filename);

src_filename = [mexname '.c'];
src_fullpath = fullfile (d, src_filename);

dir_src = dir (src_fullpath);
dir_mex = dir (mex_fullpath);

if isempty (dir_src)
    error ('STK:stk_config_buildmex:FileNotFound', ...
        sprintf ('File %s not found', src_filename));
end

compile = opts.force_recompile || ...
    (isempty (dir_mex)) || (dir_mex.datenum < dir_src.datenum);

if ~ isempty (includes)
    for k = 1:(length (includes))
        dir_hdr = dir (fullfile (opts.include_dir, includes{k}));
        if isempty (dir_hdr)
            error ('STK:stk_config_buildmex:FileNotFound', ...
                sprintf ('Header file %s not found', includes{k}));
        end
        compile = compile || (dir_mex.datenum < dir_hdr.datenum);
    end
end

if compile,
    
    fprintf ('[stk_config_buildmex] Compiling MEX-file %s... ', mexname);
    
    cd (d);
    
    include = sprintf ('-I%s', opts.include_dir);
    mex (src_filename, include);
    
    if ~ strcmp (d, d)
        if ~ exist (d, 'dir')
            mkdir (d);
        end
        movefile (fullfile (d, mex_filename), d);
    end
    
    fprintf ('ok.\n');  fflush (stdout);
    
end

end % function stk_compile
