% STK_COMPILE_ALL compile all MEX-files in the STK toolbox

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function stk_compile_all (force_recompile)

root = stk_get_root ();
here = pwd ();

opts.force_recompile = ~((nargin == 0) || ~force_recompile);
opts.include_dir = fullfile(root, 'misc', 'include');

src_dir = fullfile (root, 'misc', 'dist', 'private');
dst_dir = src_dir;
stk_compile (dst_dir, src_dir, opts, 'stk_dist_matrixx');
stk_compile (dst_dir, src_dir, opts, 'stk_dist_matrixy');
stk_compile (dst_dir, src_dir, opts, 'stk_dist_pairwise');
stk_compile (dst_dir, src_dir, opts, 'stk_filldist_discr_mex');
stk_compile (dst_dir, src_dir, opts, 'stk_mindist_mex');
stk_compile (dst_dir, src_dir, opts, 'stk_gpquadform_matrixy');
stk_compile (dst_dir, src_dir, opts, 'stk_gpquadform_matrixx');
stk_compile (dst_dir, src_dir, opts, 'stk_gpquadform_pairwise');

dst_dir = fullfile (root, 'utils', '@stk_dataframe');
src_dir = fullfile (dst_dir, 'src');
stk_compile (dst_dir, src_dir, opts, 'get');
stk_compile (dst_dir, src_dir, opts, 'set');

src_dir = fullfile (root, 'sampling');
dst_dir = src_dir;
stk_compile (dst_dir, src_dir, opts, 'stk_sampling_vdc_rr2');

% add other MEX-files to be compiled here

cd (here);

end % function stk_compile_all


function stk_compile (dst_dir, src_dir, opts, mexname, varargin)

fprintf ('MEX-file %s... ', mexname);

filename = [mexname '.' mexext];
src_file = fullfile (src_dir, sprintf ('%s.c', mexname));
mex_file = fullfile (dst_dir, filename);

dir_src = dir (src_file);
dir_mex = dir (mex_file);

if isempty (dir_src)
    stk_error (sprintf ('File %s not found', src_file), 'FileNotFound');
end

compile = opts.force_recompile || (isempty(dir_mex)) ...
    || (dir_mex.datenum < dir_src.datenum);

if compile,
    
    cd (src_dir);
    
    mex (src_file, sprintf('-I%s', opts.include_dir, varargin{:}));
    
    if ~strcmp (src_dir, dst_dir)
        system (sprintf('mv %s/%s %s', src_dir, filename, dst_dir));
    end
    
end

fid = fopen (mex_file, 'r');
if fid ~= -1,
    fprintf ('ok.\n');
    fclose (fid);
else
    fprintf ('not found.\n\n');
    error ('compilation error ?\n');
end

end
