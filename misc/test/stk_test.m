% STK_TEST performs tests for a given M-file.
%
% FIXME: missing doc

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>
%
%    This file has been adapted from test.m in Octave 3.6.2,  distributed
%    under the GNU General Public Licence version 3 (GPLv3). The original
%    copyright notice was as follows:
%
%        Copyright (C) 2005-2012 Paul Kienzle

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

%%
% Octave doc, to be adapted...
%
% -*- texinfo -*-
% @deftypefn  {Command} {} test @var{name}
% @deftypefnx {Command} {} test @var{name} quiet|normal|verbose
% @deftypefnx {Function File} {} test ('@var{name}', 'quiet|normal|verbose', @var{fid})
% @deftypefnx {Function File} {} test ([], 'explain', @var{fid})
% @deftypefnx {Function File} {@var{success} =} test (@dots{})
% @deftypefnx {Function File} {[@var{n}, @var{max}] =} test (@dots{})
% @deftypefnx {Function File} {[@var{code}, @var{idx}] =} test ('@var{name}', 'grabdemo')
%
% Perform tests from the first file in the loadpath matching @var{name}.
% @code{test} can be called as a command or as a function.  Called with
% a single argument @var{name}, the tests are run interactively and stop
% after the first error is encountered.
%
% With a second argument the tests which are performed and the amount of
% output is selected.
%
% @table @asis
% @item 'quiet'
%  Don't report all the tests as they happen, just the errors.
%
% @item 'normal'
% Report all tests as they happen, but don't do tests which require
% user interaction.
%
% @item 'verbose'
% Do tests which require user interaction.
% @end table
%
% The argument @var{fid} can be used to allow batch processing.  Errors
% can be written to the already open file defined by @var{fid}, and
% hopefully when Octave crashes this file will tell you what was happening
% when it did.  You can use @code{stdout} if you want to see the results as
% they happen.  You can also give a file name rather than an @var{fid}, in
% which case the contents of the file will be replaced with the log from
% the current test.
%
% Called with a single output argument @var{success}, @code{test} returns
% true if all of the tests were successful.  Called with two output arguments
% @var{n} and @var{max}, the number of successful tests and the total number
% of tests in the file @var{name} are returned.
%
% If the second argument is 'explain', then @var{name} is ignored and an
% explanation of the line markers used is written to the file @var{fid}.
% @seealso{assert, error, example}
% @end deftypefn

function varargout = stk_test (varargin)

varargout = cell (1, nargout);

if exist ('OCTAVE_VERSION', 'builtin') == 5
    
    % Use the original test function shipped with Octave
    [varargout{:}] = test (varargin{:});
    
else  % Matlab
    
    % Use the one that is provided with STK
    [varargout{:}] = stk_test_ (varargin{:});
    
end % if

end % function


function [x__ret1, x__ret2, x__ret3] = stk_test_ (x__name, x__flag, x__fid)

SIGNAL_FAIL  = '!!!!! ';  % prefix: test had an unexpected result
SIGNAL_EMPTY = '????? ';  % prefix: no tests in file
SIGNAL_BLOCK = '***** ';  % prefix: code for the test
SIGNAL_FILE  = '>>>>> ';  % prefix: new test file

nb_expected_failures = 0;  % counter for expected failures ('xtest' blocks)

% default value for input arg #2: 'quiet'
if nargin < 2 || isempty(x__flag), x__flag = 'quiet'; end

% default value for input arg #3: []  (interactive mode, output --> stdout)
if nargin < 3, x__fid = []; end

if (nargin < 1) || (nargin > 3),
    error('Incorrect number of input arguments.');
end

% first argument must be a non-empty string
if isempty(x__name) || ~ischar(x__name),
    error('The first argument of stk_test() must be a non-empty string');
end

% second argument must be a non-empty string
if ~isempty(x__flag) && ~ischar(x__flag),
    error('The first argument of stk_test() must be either empty or a string');
end

x__batch = (~ isempty (x__fid));

% Decide if error messages should be collected.
x__close_fid = 0;
if (x__batch)
    if (ischar (x__fid))
        x__fid = fopen (x__fid, 'wt');
        if (x__fid < 0)
            error ('test: could not open log file');
        end
        x__close_fid = 1;
    end
    %fprintf (x__fid, '%sprocessing %s\n', SIGNAL_FILE, x__name);
    %fflush (x__fid);
else
    x__fid = stdout;
end

switch x__flag,
    case 'normal',
        x__verbose = x__batch;
    case 'quiet',
        x__verbose = 0;
    case 'verbose',
        x__verbose = 1;
    otherwise,
        error('test: unknown flag ''%s''', x__flag);
end

% Locate the file to test.
x__file = file_in_loadpath (x__name, 'all');
if (isempty (x__file))
    x__file = file_in_loadpath ([x__name, '.m'], 'all');
end
if (isempty (x__file))
    x__file = file_in_loadpath ([x__name, '.cc'], 'all');
end

if (iscell (x__file))
    % If repeats, return first in path.
    if (isempty (x__file))
        x__file = '';
    else
        x__file = x__file{1};
    end
end
if (isempty (x__file))
    if (exist (x__name) == 3)
        fprintf (x__fid, '%s%s source code with tests for dynamically linked function not found\n', SIGNAL_EMPTY, x__name);
    else
        fprintf (x__fid, '%s%s does not exist in path\n', SIGNAL_EMPTY, x__name);
    end
    fflush (x__fid);
    if (nargout > 0)
        x__ret1 = 0; x__ret2 = 0;
    end
    if (x__close_fid)
        fclose(x__fid);
    end
    return;
end

% Grab the test code from the file.
x__body = x__extract_test_code (x__file);

if (isempty (x__body))
    fprintf (x__fid, '%s%s has no tests available\n', SIGNAL_EMPTY, x__file);
    fflush (x__fid);
    if (nargout > 0)
        x__ret1 = 0; x__ret2 = 0;
    end
    if (x__close_fid)
        fclose(x__fid);
    end
    return;
else
    % Add a dummy comment block to the end for ease of indexing.
    if (x__body (length(x__body)) == sprintf('\n'))
        x__body = sprintf ('\n%s%%', x__body);
    else
        x__body = sprintf ('\n%s\n%%', x__body);
    end
end

% Chop it up into blocks for evaluation.
x__lineidx = find (x__body == sprintf('\n'));
x__blockidx = x__lineidx(find (~ isspace (x__body(x__lineidx+1))))+1;

% Ready to start tests ... if in batch mode, tell us what is happening.
if (x__verbose)
    disp ([SIGNAL_FILE, x__file]);
end

% Assume all tests will pass.
x__all_success = 1;

% Process each block separately, initially with no shared variables.
x__tests = 0; x__successes = 0;
x__shared_names = {};
x__shared_vals = {};
for x__i = 1:length(x__blockidx)-1
    
    % Extract the block.
    x__block = x__body(x__blockidx(x__i):x__blockidx(x__i+1)-2);
    
    % Let the user/logfile know what is happening.
    if (x__verbose)
        fprintf (x__fid, '%s%s\n', SIGNAL_BLOCK, x__block);
        fflush (x__fid);
    end
    
    % Split x__block into x__type and x__code.
    x__idx = find (~ isletter (x__block));
    if (isempty (x__idx))
        x__type = x__block;
        x__code = '';
    else
        x__type = x__block(1:x__idx(1)-1);
        x__code = x__block(x__idx(1):length(x__block));
    end
    
    % Assume the block will succeed.
    x__success = 1;
    x__msg = [];
    
    %%% SHARED
    
    if (strcmp (x__type, 'shared'))
        x__istest = 0;
        
        % Separate initialization code from variables.
        x__idx = find (x__code == sprintf('\n'));
        if (isempty (x__idx))
            x__vars = x__code;
            x__code = '';
        else
            x__vars = x__code (1:x__idx(1)-1);
            x__code = x__code (x__idx(1):length(x__code));
        end
        
        % Strip comments off the variables.
        x__idx = find(x__vars == '%');
        if (~ isempty (x__idx))
            x__vars = x__vars(1:x__idx(1)-1);
        end
        
        % Assign default values to variables.
        try
            x__vars = deblank (x__vars);
            if (~ isempty (x__vars))
                x__shared_names = {};
                while ~isempty(x__vars),
                    [x__shared_names{end+1}, x__vars] = strtok(x__vars, ', ');
                end
                x__shared_vals = repmat({[]}, 1, length(x__shared_names));
            else
                x__shared_names = {};
                x__shared_vals = {};
            end
        catch
            % Couldn't declare, so don't initialize.
            x__code = '';
            x__success = 0;
            x__msg = sprintf ('%sshared variable initialization failed\n', ...
                SIGNAL_FAIL);
        end
        
        % Initialization code will be evaluated below.
        
    elseif (strcmp (x__type, 'end'))
        % end simply declares the end of a previous function block.
        % There is no processing to be done here, just skip to next block.
        x__istest = 0;
        x__code = '';
        
        %%% ASSERT
        
    elseif strcmp(x__type, 'assert')
        x__istest = 1;
        % Put the keyword back on the code.
        x__code = x__block;
        % The code will be evaluated below as a test block.
        
        %%% ERROR/WARNING
        
    elseif (strcmp (x__type, 'error') || strcmp(x__type, 'warning'))
        x__istest = 1;
        x__warning = strcmp (x__type, 'warning');
        [x__pattern, x__id, x__code] = getpattern (x__code);
        if (x__id)
            x__patstr = ['id=',x__id];
        else
            x__patstr = ['<',x__pattern,'>'];
        end
        
        % FIXME: in the Octave version, syntax errors are counted as
        % failure, even for an 'error' block. This won't be the case here.
        
        if (x__success)
            x__success = 0;
            %x__warnstate = warning ('query', 'quiet');
            %warning ('on', 'quiet');
            try
                % This code is supposed to fail, so we don't save the output
                % into x__shared_vals.
                eval_test_code(x__code, x__shared_names, x__shared_vals{:});
                if (~ x__warning)
                    x__msg = sprintf ('%sexpected %s but got no error\n', ...
                        SIGNAL_FAIL, x__patstr);
                else
                    if (~ isempty (x__id))
                        [ignore_arg, x__err] = lastwarn;
                        x__mismatch =~strcmp (x__err, x__id);
                    else
                        x__err = trimerr (lastwarn, 'warning');
                        x__mismatch = isempty (regexp (x__err, x__pattern, 'once'));
                    end
                    %warning (x__warnstate.state, 'quiet');
                    if (isempty (x__err))
                        x__msg = sprintf ('%sexpected %s but got no warning\n', ...
                            SIGNAL_FAIL, x__patstr);
                    elseif (x__mismatch)
                        x__msg = sprintf ('%sexpected %s but got %s\n', ...
                            SIGNAL_FAIL, x__patstr, x__err);
                    else
                        x__success = 1;
                    end
                end
                
            catch
                if (~ isempty (x__id))
                    [ignore_arg, x__err] = lasterr();
                    x__mismatch =~strcmp (x__err, x__id);
                else
                    x__err = trimerr (lasterr(), 'error');
                    x__mismatch = isempty (regexp (x__err, x__pattern, 'once'));
                end
                %warning (x__warnstate.state, 'quiet');
                if (x__warning)
                    x__msg = sprintf ('%sexpected warning %s but got error %s\n', ...
                        SIGNAL_FAIL, x__patstr, x__err);
                elseif (x__mismatch)
                    x__msg = sprintf ('%sexpected %s but got %s\n', ...
                        SIGNAL_FAIL, x__patstr, x__err);
                else
                    x__success = 1;
                end
            end
            clear x__testx__;
        end
        % Code already processed.
        x__code = '';
        
        %%% TEST
        
    elseif (strcmp (x__type, 'test') || strcmp (x__type, 'xtest'))
        x__istest = 1;
        % Code will be evaluated below.
        
        %%% Comment block.
        
    elseif ((x__block(1) == '%') || (x__block(1) == '#'))
        x__istest = 0;
        x__code = ''; % skip the code
        
        %%% Unknown block.
        
    else
        x__istest = 1;
        x__success = 0;
        x__msg = sprintf ('%sunknown test type!\n', SIGNAL_FAIL);
        x__code = ''; % skip the code
    end
    
    % evaluate code for test, shared, and assert.
    if (~ isempty(x__code))
        try
            % FIXME: need to check for embedded test functions, which cause
            % segfaults, until issues with subfunctions in functions are resolved.
            embed_func = regexp (x__code, '^\s*function ', 'once', 'lineanchors');
            if (isempty (embed_func))
                [x__shared_vals{:}] = eval_test_code(x__code, ...
                    x__shared_names, x__shared_vals{:});
            else
                error (['Functions embedded in %!test blocks are not allowed.\n', ...
                    'Use the %!function/%!end syntax instead to define shared functions for testing.\n']);
            end
        catch
            if (strcmp (x__type, 'xtest'))
                x__msg = sprintf ('%sknown failure\n%s', SIGNAL_FAIL, lasterr ());
                nb_expected_failures = nb_expected_failures + 1;
            else
                x__msg = sprintf ('%stest failed\n%s', SIGNAL_FAIL, lasterr ());
                x__success = 0;
            end
            if (isempty (lasterr ()))
                error ('empty error text, probably Ctrl-C --- aborting');
            end
        end
        clear x__testx__;
    end
    
    % All done.  Remember if we were successful and print any messages.
    if (~ isempty (x__msg))
        % Make sure the user knows what caused the error.
        if (~ x__verbose)
            fprintf (x__fid, '%s%s\n', SIGNAL_BLOCK, x__block);
            fflush (x__fid);
        end
        fprintf(x__fid, '%s', x__msg);
        fprintf(x__fid, '%s', sprintf('\n'));
        fflush (x__fid);
        % FIXME: Dump the shared variables to x__fid... Octave uses fdisp()
        % to do that, but Matlab doesn't have this function
    end
    if (x__success == 0)
        x__all_success = 0;
        % Stop after one error if not in batch mode.
        if (~ x__batch)
            if (nargout > 0)
                x__ret1 = 0; x__ret2 = 0;
            end
            if (x__close_fid)
                fclose(x__fid);
            end
            return;
        end
    end
    x__tests = x__tests + x__istest;
    x__successes = x__successes + x__success * x__istest;
end

if nargout == 0
    if x__tests || (nb_expected_failures > 0)
        if (nb_expected_failures)
            fprintf ('PASSES %d out of %d tests (%d expected failures)\n', ...
                x__successes, x__tests, nb_expected_failures);
        else
            fprintf ('PASSES %d out of %d tests\n', x__successes, x__tests);
        end
    else
        fprintf ('%s%s has no tests available\n', SIGNAL_EMPTY, x__file);
    end
elseif (nargout == 1)
    x__ret1 = x__all_success;
else
    x__ret1 = x__successes;
    x__ret2 = x__tests;
    x__ret3 = nb_expected_failures;
end

end % function


%%%%%%%%%%%%%%%%%%
% eval_test_code %
%%%%%%%%%%%%%%%%%%
%
% Evaluate a block of code in a 'controlled' environment.
%
function varargout = eval_test_code(x__code, x__list_shared, varargin)

% Check input arguments
if length(x__list_shared) ~= length(varargin),
    error('Incorrect argument sizes.');
end

% Protect variable names x__list_shared, x__i
for i = 1:length(x__list_shared),
    if strcmp(x__list_shared{i}, 'x__list_shared'),
        error('x__list_shared cannot be used as a shared variable');
    elseif strcmp(x__list_shared{i}, 'x__i'),
        error('x__i cannot be used as a shared variable');
    end
end

% Prepare shared variables
for x__i = 1:length(x__list_shared)
    eval(sprintf('%s = varargin{%d};', x__list_shared{x__i}, x__i));
end

% Run the code
if exist ('OCTAVE_VERSION', 'builtin') == 5  % Octave

    % Run without output capture (evalc is not implemented yet in Octave)
    eval (x__code);

else  % Matlab

    % Run with output capture
    % (TODO: compare the output with a reference, if provided)
    gobble_output = evalc (x__code);  %#ok<NASGU>

end

% Save shared variables
varargout = cell(1, length(x__list_shared));
for x__i = 1:length(x__list_shared),
    if ~exist(x__list_shared{x__i}, 'var'),
        varargout{x__i} = [];
    else
        varargout{x__i} = eval(x__list_shared{x__i});
    end
end

end % function


%%%%%%%%%%%%%%
% getpattern %
%%%%%%%%%%%%%%
%
% Strip <pattern> from '<pattern> code'.
% Also handles 'id=ID code'
%
function [pattern, id, rest] = getpattern (str)

pattern = '.';
id = [];
rest = str;
str = trimleft (str);
if (~ isempty (str) && str(1) == '<')
    close = index (str, '>');
    if (close)
        pattern = str(2:close-1);
        rest = str(close+1:end);
    end
elseif (strncmp (str, 'id=', 3))
    [id, rest] = strtok (str(4:end));
end

end % function


%%%%%%%%%%%
% trimerr %
%%%%%%%%%%%
%
% Strip '.*prefix:' from '.*prefix: msg\n' and strip trailing blanks.
%
function msg = trimerr (msg, prefix)

idx = index (msg, [prefix, ':']);
if (idx > 0)
    msg(1:idx+length(prefix)) = [];
end
msg = trimleft (deblank (msg));

end % function


%%%%%%%%%%%%
% trimleft %
%%%%%%%%%%%%
%
% Strip leading blanks from string.
%
function str = trimleft (str)

idx = find (isspace (str));
leading = find (idx == 1:length(idx));
if (~ isempty (leading))
    str = str(leading(end)+1:end);
end

end % function


%%%%%%%%%%%%%%%%%%%%%%%%
% x__extract_test_code %
%%%%%%%%%%%%%%%%%%%%%%%%
%
function body = x__extract_test_code (nm)

fid = fopen (nm, 'rt');
if fid == -1,
    error(sprintf('File %s cannot be opened.', nm));
end

body = '';
if (fid >= 0)
    while (~ feof (fid))
        ln = fgetl (fid);
        if (length (ln) >= 2 && strcmp (ln(1:2), '%!'))
            body = [body, sprintf('\n')];
            if (length(ln) > 2)
                body = [body, ln(3:end)];
            end
        end
    end
    fclose (fid);
end

end % function


%% Tests of 'assert' blocks

%!assert(isempty([]))      % support for test assert shorthand
%!assert((1 + 1) == 2)

%% Tests of shared variables

% Default: variables are not shared between blocks.
%!test a=1;
%!test assert(~exist('a'));

% 'shared' blocks allow to declare a variable shared by several blocks
%!shared a              % create a shared variable
%!test a = 3;           % assign to a shared variable
%!test assert(a == 3);  % variable should equal 3 in this second 'test' block

% Each 'shared' blocks deletes previously declared shared variables
%!shared b, c                % replace shared variables {'a'} --> {'b', 'c'}
%!test assert(~exist('a'));  % a no longer exists
%!test assert(isempty(b));   % variables start off empty

%!shared a                   % recreate a shared variable that had been deleted
%!test assert (isempty(a));  % it is empty, even though it was equal to 3 before

%!shared a, b, c            % creates three shared variables
%! a = 1; b = 2; c = 3;     % give values to all variables, in the same block
%!assert(isequal([a, b, c], [1, 2, 3]));   % test all of them together
%!test c=6;                 % update a value
%!test                      % show that the update sticks between blocks
%! assert(isequal([a, b, c], [1, 2, 6]));
%!shared                    % clear all shared variables
%!assert(~exist('a'))       % show that they are cleared

%% Tests for 'error' and 'warning' blocks

%!error test                   % not enough input arguments
%!error test(1, 2, 3, 4)       % too many input args
%!error <garbage> garbage      % usage on nonexistent function should be

% When used without a pattern <>, 'error' block succeed on any error
%!error stt_test('test', 'bogus');   % undefined function error
%!error stk_test('test', 'bogus');   % error raised by stk_test itself

% !test lastwarn();        % clear last warning just in case
% !warning <worry about>   % we expect a warning msg including "worry about"
% ! warning('Don''t worry about this warning');

%% Tests the behaviour of stk_test() itself

% The number of input arguments should be between one and three
%!error stk_test();
%!error stk_test('disp', 'verbose', [], 'extra arg !!!');

% The first argument of stk_test() must be a non-empty string
%!error stk_test([])
%!error stk_test(0.0)

% The second argument of stk_test() must be a either empty, or one of the
%%! following strings: normal, quiet, verbose
%!error stk_test('stk_mindist', 0.0)
%!error <unknown flag> stk_test('stk_mindist', 'dudule')

%% Failure tests
% All the following should fail. These tests should be disabled unless you
% are developing stk_test() since users don't like to be presented with
% expected failures.  Use % ! to disable.

% !xtest  error('This test is known to fail') % expected failure
% !test   error('---------Failure tests.  Use test(''test'',''verbose'',1)');
% !test   assert(1 == 2);
% !bogus                     % unknown block type
% !error  toeplitz([1,2,3]); % correct usage
% !shared garbage in         % variables must be comma separated
% !test   }{                 % syntax errors fail properly
% !error  'succeeds.';       % error test fails if code succeeds
% !error  <wrong pattern> error('message')  % error pattern must match
