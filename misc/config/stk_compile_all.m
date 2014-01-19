% STK_COMPILE_ALL compile all MEX-files in the STK toolbox

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

src_dir = fullfile (root, 'utils', 'arrays', '@stk_dataframe', 'private');
dst_dir = src_dir;
stk_compile (dst_dir, src_dir, opts, 'get_column_number');

src_dir = fullfile (root, 'sampling');
dst_dir = src_dir;
stk_compile (dst_dir, src_dir, opts, 'stk_sampling_vdc_rr2');

% add other MEX-files to be compiled here

cd (here);

% Octave must be restarted when MEX-files are compiled in private folders
% (see https://savannah.gnu.org/bugs/?40824)
if isoctave, warn_about_mexfiles_in_private_folders; end

end % function stk_compile_all


function stk_compile (dst_dir, src_dir, opts, mexname, varargin)

fprintf ('MEX-file %s... ', mexname);

mex_filename = [mexname '.' mexext];
mex_fullpath = fullfile (dst_dir, mex_filename);

src_filename = [mexname '.c'];
src_fullpath = fullfile (src_dir, src_filename);

dir_src = dir (src_fullpath);
dir_mex = dir (mex_fullpath);

if isempty (dir_src)
    stk_error (sprintf ('File %s not found', src_filename), 'FileNotFound');
end

compile = opts.force_recompile || (isempty(dir_mex)) ...
    || (dir_mex.datenum < dir_src.datenum);

if compile,
    
    cd (src_dir);
    
    include = sprintf('-I%s', opts.include_dir);
    mex (src_filename, include, varargin{:});
    
    if ~strcmp (src_dir, dst_dir)
        movefile (fullfile (src_dir, mex_filename), dst_dir);
    end
    
end

fid = fopen (mex_fullpath, 'r');
if fid ~= -1,
    fprintf ('ok.\n');
    fclose (fid);
else
    fprintf ('not found.\n\n');
    error ('compilation error ?\n');
end

end % function stk_compile


function warn_about_mexfiles_in_private_folders ()

try
    n = 5;  d = 2;
    x = rand (n, n);
    D = stk_dist (x);  % calls a MEX-file internally
    assert (isequal (size (D), [n n]));
catch
    err = lasterror ();
    if (~ isempty (regexp (err.message, 'stk_dist_matrixx'))) ...
        && (~ isempty (regexp (err.message, 'undefined')))
        fprintf ('\n\n');
        error (sprintf (['\n\n' ...
            '!>>>>>> PLEASE RESTART OCTAVE BEFORE USING STK <<<<<<!\n' ...
            '!                                                    !\n' ...
            '! Some STK functions implemented as MEX-files have   !\n' ...
            '! just been compiled, but will not be detected until !\n' ...
            '! Octave is restarted.                               !\n' ...
            '!                                                    !\n' ...
            '! We apologize for this inconvenience, which is      !\n' ...
            '! related to a known Octave bug (bug #40824), that   !\n' ...
            '! will hopefully be fixed in the near future.        !\n' ...
            '! (see https://savannah.gnu.org/bugs/?40824)         !\n' ...
            '!                                                    !\n' ...          
            '!>>>>>> PLEASE RESTART OCTAVE BEFORE USING STK <<<<<<!\n' ...
            '\n']));
    else
        rethrow (err);
    end
end
    
end % function warn_about_mexfiles_in_private_folders
