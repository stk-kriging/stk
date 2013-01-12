% STK_COMPILE_ALL compile all MEX-files in the STK toolbox

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
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

function stk_compile_all(force_recompile)

root = stk_get_root();
here = pwd();

force_recompile = ~((nargin == 0) || ~force_recompile);

d = fullfile(root, 'misc', 'dist');
stk_compile(d, 'stk_mindist', force_recompile);
stk_compile(d, 'stk_dist_matrixx', force_recompile);
stk_compile(d, 'stk_dist_matrixy', force_recompile);
stk_compile(d, 'stk_dist_pairwise', force_recompile);
stk_compile(d, 'stk_filldist_discretized', force_recompile);

% add other MEX-files to be compiled here

cd(here);

end


function stk_compile(folder, mexname, force_recompile, varargin)

fprintf('MEX-file %s... ', mexname);

cd(folder);

if force_recompile || exist(mexname, 'file') ~= 3;
    mex(sprintf('%s.c',mexname), varargin{:});
end

fid = fopen([mexname '.' mexext], 'r');
if fid ~= -1,
    fprintf('ok.\n');
    fclose(fid);
else
    fprintf('not found.\n\n');
    error('compilation error ?\n');
end

end
