% STK_RUNTESTS runs all tests in a given directory (or in STK's searchpath).

% Copyright Notice
%
%    Copyright (C) 2015, 2017-2019 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
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
%               (https://github.com/stk-kriging/stk/)
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

function test_results = stk_runtests (dirs)

if nargin == 0
    
    % Scan all STK directories if no input argument is provided
    dirs = stk_init ('genpath');
    
else % The input argument is expected to be either a directory name...
    
    if ischar (dirs)
        dirs = {dirs};
    elseif ~ iscell (dirs)  %  ...or a cell array of directory names.
        stk_error (['A directory name, or a cell array of ' ...
            'directory names, was expected'], 'TypeMismatch');
    end
    
end % if

% Use the replacement that is provided with STK
res = stk_runtests_ (dirs);

if nargout > 0
    test_results = res;
end

end % function


function res = stk_runtests_ (dirs)

t0 = tic ();

% Current directory
here = pwd ();

% Prepare output struct
res = struct (       ...
    'n_total',  0,   ...
    'n_pass',   0,   ...
    'n_xfail',  0,   ...
    'n_files',  0,   ...
    'n_notest', 0,   ...
    'n_dirs',   0,   ...
    'err',      {{}} );

% Run tests all available tests in each directory
for i = 1:(numel (dirs))
    
    if ~ exist (dirs{i}, 'dir')
        stk_error (sprintf ('Directory not found: %s', dirs{i}), 'InvalidArgument');
    end
    
    % Get absolute path
    cd (dirs{i});  dirname = pwd ();  cd (here);
    
    [np, nt, nx, nn, nf, nd, res.err] = ...
        run_all_tests (dirname, dirname, res.err);
    
    res.n_total  = res.n_total  + nt;
    res.n_pass   = res.n_pass   + np;
    res.n_xfail  = res.n_xfail  + nx;
    res.n_files  = res.n_files  + nf;
    res.n_notest = res.n_notest + nn;
    res.n_dirs   = res.n_dirs   + nd;
    
end

res.runtime = toc (t0);

if res.n_dirs > 1
    fprintf ('*** Summary for all %d directories:\n', res.n_dirs);
    fprintf ('*** --> passed %d/%d tests', res.n_pass, res.n_total);
    fprintf ('  [%d expected failures]\n', res.n_xfail);
    fprintf ('*** --> %d/%d files had no tests\n', res.n_notest, res.n_files);
    fprintf ('*** --> RUNTIME: %.2f seconds\n\n', res.runtime);
end

if ~ isempty (res.err)
    fprintf ('!!! Summary of failed tests:\n');
    for i = 1:(size (res.err, 1))
        fprintf ('!!! %s [%d/%d]\n', res.err{i,1}, ...
            res.err{i,2} - res.err{i,3}, res.err{i,2});
    end
end

end % function


%%%%%%%%%%%%%%%%%
% run_all_tests %
%%%%%%%%%%%%%%%%%

function [n_pass, n_total, n_xfail, n_notest, n_files, n_dirs, err] ...
    = run_all_tests (testdir, basedir, err)

% list directory content
dirinfo = dir(testdir);
flist = {dirinfo.name};

here = pwd ();  cd (basedir);

fprintf ('Processing files in %s:\n\n', testdir);
fflush (stdout);

% init counters
n_total  = 0;
n_pass   = 0;
n_xfail  = 0;
n_files  = 0;
n_notest = 0;
n_dirs   = 1;

% list of subdirectories to be processed
subdirs_class = {};
subdirs_private = {};

t0 = tic ();

for i = 1:numel (flist)
    f = flist{i};
    ff = fullfile(testdir, f);
    if (length (f) > 2) && strcmp (f((end-1):end), '.m')
        n_files = n_files + 1;
        print_test_file_name (f);
        if has_tests (ff)
            % Silence all warnings & prepare for warning detection.
            s = warning_off ();
            try
                % Do the actual tests.
                [p, n, nx] = stk_test (ff, 'quiet', stdout);
                % Note: the presence of the third argument (fid=stdout) forces
                % stk_test in batch mode, which means that it doesn't stop at
                % the first failed test.
                print_pass_fail (n, p);
                n_total = n_total + n;
                n_pass  = n_pass  + p;
                n_xfail = n_xfail + nx;
                % Record function name if at least one test failed
                if p < n
                    err = [err; {ff, n, p}];
                end
                % Deal with warnings
                if ~ isempty (lastwarn ())
                    fprintf (' (warnings)');
                end
                % Indicate if there were expected failures
                if nx > 0
                    fprintf (' [%d expected failures]', nx);
                end
                warning (s);
            catch
                % Restore warning state after error
                warning (s);
                rethrow (lasterror ());
            end
        else
            n_notest = n_notest + 1;
            fprintf (' NO TESTS');
        end
        fprintf ('\n');
        fflush (stdout);
    elseif dirinfo(i).isdir && (f(1) == '@')
        subdirs_class{end+1} = ff;
    elseif dirinfo(i).isdir && strcmp(f, 'private')
        subdirs_private{end+1} = ff;
    end
end

runtime = toc (t0);

fprintf (['   --> passed %d/%d tests ' ...
    '[%d expected failures]\n'], n_pass, n_total, n_xfail);
fprintf ('   --> %d/%d files had no tests\n', n_notest, n_files);
fprintf ('   --> RUNTIME: %.2f seconds\n\n', runtime);

for i = 1:(length (subdirs_class))
    
    [p, n, nx, nnt, nf, nd, err] = run_all_tests ...
        (subdirs_class{i}, pwd(), err);
    
    n_total  = n_total  + n;
    n_pass   = n_pass   + p;
    n_xfail  = n_xfail  + nx;
    n_files  = n_files  + nf;
    n_notest = n_notest + nnt;
    n_dirs   = n_dirs   + nd;
end

for i = 1:(length (subdirs_private))
    
    [p, n, nx, nnt, nf, nd, err] = run_all_tests ...
        (subdirs_private{i}, subdirs_private{i}, err);
    
    n_total  = n_total  + n;
    n_pass   = n_pass   + p;
    n_xfail  = n_xfail  + nx;
    n_files  = n_files  + nf;
    n_notest = n_notest + nnt;
    n_dirs   = n_dirs   + nd;
end

cd (here);

end % function


%%%%%%%%%%%%%
% has_tests %
%%%%%%%%%%%%%

function retval = has_tests (f)

fid = fopen (f);
if (fid >= 0)
    str = fread (fid, '*char')';
    fclose (fid);
    retval = ~ isempty (regexp ...
        (str, '^%!(test|assert|error|warning)', 'lineanchors'));
else
    error ('runtests: fopen failed: %s', f);
end

end % function


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

end % function


%%%%%%%%%%%%%%%%%%%%%%%%
% print_test_file_name %
%%%%%%%%%%%%%%%%%%%%%%%%

function print_test_file_name (nm)

filler = repmat ('.', 1, 50 - length(nm));
fprintf ('  %s %s', nm, filler);

end % function


%%%%%%%%%%%%%%%
% warning_off %
%%%%%%%%%%%%%%%

function s = warning_off ()

s = warning ('off', 'all');

% Check whether warnings can be still be recovered by lastwarn
%   (see https://savannah.gnu.org/bugs/?41028)

lastwarn ('');
warning ('ah:ah', 'toto');
[msg, id] = lastwarn ();

if ~ (strcmp (id, 'ah:ah') && strcmp (msg, 'toto'))
    warning ('on', 'all');
    for i = 1:(length (s))
        if ~ isempty (regexp (s(i).identifier, '^Octave:', 'once'))
            warning (s(i).state, s(i).identifier);
        end
    end
end

lastwarn ('');

end % function


%#ok<*AGROW>
