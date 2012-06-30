% STK_RUNTESTS runs all tests in a given directory (or in STK's searchpath).
%
% FIXME: missing doc
%

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
%    This file has been adapted from runtests.m in Octave 3.6.2 (which is  
%    distributed under the GNU General Public Licence version 3 (GPLv3). 
%    The original copyright notice was as follows:
%
%        Copyright (C) 2010-2012 John W. Eaton
%
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

%% Original Octave doc, to be adapted
% -*- texinfo -*-
% @deftypefn  {Function File} {} runtests ()
% @deftypefnx {Function File} {} runtests (@var{directory})
% Execute built-in tests for all function files in the specified directory.
% If no directory is specified, operate on all directories in Octave's
% search path for functions.
% @seealso{rundemos, path}
% @end deftypefn

function stk_runtests(directory)

if nargin == 0
    % scan all STK directories if no input argument is provided
    dirs = stk_path();
else
    % otherwise, directory is expected to be a valid direcoty name
    if ~exist(directory, 'dir')
        error('Directory not found.');
    end

    dirs = {directory};
end

% number of directories to be explored
nb_dirs = numel(dirs);

% run tests all available tests in each directory
n_total = 0; n_pass = 0; n_files = 0; n_notest = 0;
for i = 1:nb_dirs
    [n_pass_, n_total_, n_notest_, n_files_] = run_all_tests(dirs{i});
    n_total  = n_total + n_total_;
    n_pass   = n_pass + n_pass_;
    n_files  = n_files + n_files_;
    n_notest = n_notest + n_notest_;
end

if nb_dirs > 1,
    fprintf('Summary for all %d directories:\n', nb_dirs);
    fprintf(' --> passed %d/%d tests\n', n_pass, n_total);
    fprintf(' --> %d/%d files had no tests\n', n_notest, n_files);
end

end


%%%%%%%%%%%%%%%%%
% run_all_tests %
%%%%%%%%%%%%%%%%%

function [n_pass, n_total, n_notest, n_files] = run_all_tests(directory)

% list directory content
dirinfo = dir(directory);
flist = {dirinfo.name};

here = pwd(); cd(directory);

fprintf ('Processing files in %s:\n\n', directory);
fflush (stdout);

n_total = 0;
n_pass = 0;
n_files = 0;
n_notest = 0;
for i = 1:numel (flist)
    f = flist{i};
    if (length (f) > 2 && strcmp (f((end-1):end), '.m'))
        n_files = n_files + 1;
        print_test_file_name (f);
        if has_tests(f)
            [p, n] = stk_test (f, 'quiet', stdout);
            % Note: the presence of the third argument (fid=stdout) forces
            % stk_test in batch mode, which means that it doesn't stop at
            % the first failed test.
            print_pass_fail (n, p);
            fflush (stdout);
            n_total = n_total + n;
            n_pass = n_pass + p;
        else
            n_notest = n_notest + 1;
            fprintf(' NO TESTS\n');
        end
    end
end
fprintf('   --> passed %d/%d tests\n', n_pass, n_total);
fprintf('   --> %d/%d files had no tests\n', n_notest, n_files);
fprintf('\n');

cd(here);

end % run_all_tests


%%%%%%%%%%%%%
% has_tests %
%%%%%%%%%%%%%

function retval = has_tests (f)

fid = fopen (f);
if (fid >= 0)
    str = fread (fid, '*char')';
    fclose (fid);
    retval =~isempty (regexp (str, '^%!(test|assert|error|warning)', 'lineanchors'));
else
    error ('runtests: fopen failed: %s', f);
end

end % has_tests


%%%%%%%%%%%%%%%%%%%
% print_pass_fail %
%%%%%%%%%%%%%%%%%%%

function print_pass_fail (n, p)

if (n > 0)
    fprintf (' PASS %2d/%-2d', p, n);
    nfail = n - p;
    if (nfail > 0)
        fprintf (' FAIL %d', nfail);
    end
end
fprintf('\n');

end % print_pass_fail


%%%%%%%%%%%%%%%%%%%%%%%%
% print_test_file_name %
%%%%%%%%%%%%%%%%%%%%%%%%

function print_test_file_name (nm)

filler = repmat('.', 1, 50 - length(nm));
fprintf('  %s %s', nm, filler);

end % print_test_file_name
