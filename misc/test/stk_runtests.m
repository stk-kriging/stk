% STK_RUNTESTS runs all tests in a given directory (or in STK's searchpath).
%
% FIXME: missing doc
%

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
%
%    This file has been adapted from runtests.m in Octave 3.6.2 (which is
%    distributed under the GNU General Public Licence version 3 (GPLv3)).
%    The original copyright notice was as follows:
%
%        Copyright (C) 2010-2012 John W. Eaton

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

function stk_runtests (directory)

if nargin == 0
    % scan all STK directories if no input argument is provided
    dirs = stk_path();
else
    % otherwise, directory is expected to be a valid directory name
    if ~exist(directory, 'dir')
        error('Directory not found.');
    end
    here = pwd();
    cd(directory);
    dirs = {pwd()}; % get absolute path
    cd(here);
end

% number of directories to be explored
nb_topdirs = numel(dirs);

% run tests all available tests in each directory
n_total = 0; n_pass = 0; n_files = 0; n_notest = 0; n_dirs = 0;
for i = 1:nb_topdirs
    [np, nt, nn, nf, nd] = run_all_tests(dirs{i}, dirs{i});
    n_total  = n_total  + nt;
    n_pass   = n_pass   + np;
    n_files  = n_files  + nf;
    n_notest = n_notest + nn;
    n_dirs   = n_dirs   + nd;
end

if n_dirs > 1,
    fprintf('Summary for all %d directories:\n', n_dirs);
    fprintf(' --> passed %d/%d tests\n', n_pass, n_total);
    fprintf(' --> %d/%d files had no tests\n', n_notest, n_files);
end

end % function stk_runtests


%%%%%%%%%%%%%%%%%
% run_all_tests %
%%%%%%%%%%%%%%%%%

function [n_pass, n_total, n_notest, n_files, n_dirs] ...
    = run_all_tests (testdir, basedir)

% list directory content
dirinfo = dir(testdir);
flist = {dirinfo.name};

here = pwd(); cd(basedir);

fprintf ('Processing files in %s:\n\n', testdir);
fflush (stdout);

% init counters
n_total  = 0;
n_pass   = 0;
n_files  = 0;
n_notest = 0;
n_dirs   = 1;

% list of subdirectories to be processed
subdirs_class = {};
subdirs_private = {};

for i = 1:numel (flist)
    f = flist{i};
    ff = fullfile(testdir, f);
    if (length (f) > 2) && strcmp (f((end-1):end), '.m')
        n_files = n_files + 1;
        print_test_file_name (f);
        if has_tests(ff)
            % Silence all warnings & prepare for warning detection.
            s = warning('off', 'all'); lastwarn('');
            % Do the actual tests.
            [p, n] = stk_test (ff, 'quiet', stdout);
            % Note: the presence of the third argument (fid=stdout) forces
            % stk_test in batch mode, which means that it doesn't stop at
            % the first failed test.
            print_pass_fail(n, p);
            n_total = n_total + n;
            n_pass  = n_pass  + p;
            % deal with warnings
            if ~isempty(lastwarn()), fprintf(' (warnings)'); end
            warning(s);
        else
            n_notest = n_notest + 1;
            fprintf(' NO TESTS');
        end
        fprintf('\n');
        fflush(stdout);
    elseif dirinfo(i).isdir && (f(1) == '@')
        subdirs_class{end+1} = ff; %#ok<AGROW>
        n_dirs = n_dirs + 1;
    elseif dirinfo(i).isdir && strcmp(f, 'private')
        subdirs_private{end+1} = ff; %#ok<AGROW>
        n_dirs = n_dirs + 1;
    end
end
fprintf('   --> passed %d/%d tests\n', n_pass, n_total);
fprintf('   --> %d/%d files had no tests\n', n_notest, n_files);
fprintf('\n');

for i = 1:length(subdirs_class)
    [p, n, nnt, nf] = run_all_tests(subdirs_class{i}, pwd());
    n_total  = n_total  + n;
    n_pass   = n_pass   + p;
    n_files  = n_files  + nf;
    n_notest = n_notest + nnt;
end

for i = 1:length(subdirs_private)
    [p, n, nnt, nf] = run_all_tests(subdirs_private{i}, subdirs_private{i});
    n_total  = n_total  + n;
    n_pass   = n_pass   + p;
    n_files  = n_files  + nf;
    n_notest = n_notest + nnt;
end

cd(here);

end % function run_all_tests


%%%%%%%%%%%%%
% has_tests %
%%%%%%%%%%%%%

function retval = has_tests (f)

fid = fopen (f);
if (fid >= 0)
    str = fread (fid, '*char')';
    fclose (fid);
    retval = ~isempty (regexp (str, '^%!(test|assert|error|warning)', 'lineanchors'));
else
    error ('runtests: fopen failed: %s', f);
end

end % function has_tests


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

end % function print_pass_fail


%%%%%%%%%%%%%%%%%%%%%%%%
% print_test_file_name %
%%%%%%%%%%%%%%%%%%%%%%%%

function print_test_file_name (nm)

filler = repmat('.', 1, 50 - length(nm));
fprintf('  %s %s', nm, filler);

end % function print_test_file_name
