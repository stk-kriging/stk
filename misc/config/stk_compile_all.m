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

function stk_compile_all(force_recompile)

root = stk_get_root();
here = pwd();

force_recompile = ~((nargin == 0) || ~force_recompile);

source_folder = fullfile(root, 'misc', 'dist', 'private');
output_folder = source_folder;
stk_compile('stk_dist_matrixx');
stk_compile('stk_dist_matrixy');
stk_compile('stk_dist_pairwise');
stk_compile('stk_filldist_discr_mex');
stk_compile('stk_mindist_mex');
stk_compile('stk_gpquadform_matrixy');
stk_compile('stk_gpquadform_matrixx');
stk_compile('stk_gpquadform_pairwise');

output_folder = fullfile(root, 'utils', '@stk_dataframe');
source_folder = fullfile(output_folder, 'src');
stk_compile('get');
stk_compile('set');

source_folder = fullfile(root, 'sampling');
output_folder = source_folder;
stk_compile('stk_sampling_vdc_rr2');

% add other MEX-files to be compiled here

cd(here);


    function stk_compile(mexname, varargin)
        
        fprintf('MEX-file %s... ', mexname);
        
        filename = [mexname '.' mexext];
        src_file = fullfile(source_folder, sprintf('%s.c', mexname));
        mex_file = fullfile(output_folder, filename);
        
        dir_src = dir(src_file);
        dir_mex = dir(mex_file);

        if isempty(dir_src)
            stk_error(sprintf('File %s not found', src_file), 'FileNotFound');
        end
        
        compile = force_recompile || isempty(dir_mex) ...
            || (dir_mex.datenum < dir_src.datenum);
        
        if compile,

            cd(source_folder);
                
            mex(src_file,                                           ...
                sprintf('-I%s', fullfile(root, 'misc', 'include'),  ...
                varargin{:}));

            if ~strcmp(source_folder, output_folder)
                system(sprintf('mv %s/%s %s', ...
                    source_folder, filename, output_folder));
            end

        end
                
        fid = fopen(mex_file, 'r');
        if fid ~= -1,
            fprintf('ok.\n');
            fclose(fid);
        else
            fprintf('not found.\n\n');
            error('compilation error ?\n');
        end
        
    end

end