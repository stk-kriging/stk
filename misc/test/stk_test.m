% STK_TEST performs tests for a given M-file.
%
% FIXME: missing doc

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    This file has been adapted from test.m in Octave 3.6.2,  distributed
%    under the GNU General Public Licence version 3 (GPLv3). The original
%    copyright notice was as follows:
%
%        Copyright (C) 2005-2012 Paul Kienzle
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
% If the second argument is the string 'grabdemo', the contents of the demo
% blocks are extracted but not executed.  Code for all code blocks is
% concatenated and returned as @var{code} with @var{idx} being a vector of
% positions of the ends of the demo blocks.
%
% If the second argument is 'explain', then @var{name} is ignored and an
% explanation of the line markers used is written to the file @var{fid}.
% @seealso{assert, fail, error, demo, example}
% @end deftypefn

function [x__ret1, x__ret2, x__ret3, x__ret4] = stk_test (x__name, x__flag, x__fid)
  % Information from test will be introduced by 'key'.
  persistent x__signal_fail
  x__signal_fail =  '!!!!! ';
  persistent x__signal_empty
  x__signal_empty = '????? ';
  persistent x__signal_block
  x__signal_block = '  ***** ';
  persistent x__signal_file
  x__signal_file =  '>>>>> ';
  persistent x__signal_skip
  x__signal_skip = '----- ';

  x__xfail = 0;
  x__xskip = 0;

  if (nargin < 2 || isempty (x__flag))
    x__flag = 'quiet';
  end
  if (nargin < 3)
    x__fid = [];
  end
  if (nargin < 1 || nargin > 3 ...
      || (~ ischar (x__name) && ~isempty (x__name)) || ~ischar (x__flag))
    print_usage ();
  end
  if (isempty (x__name) && (nargin ~= 3 || ~strcmp (x__flag, 'explain')))
    print_usage ();
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
    fprintf (x__fid, '%sprocessing %s\n', x__signal_file, x__name);
    fflush (x__fid);
  else
    x__fid = stdout;
  end

  if (strcmp (x__flag, 'normal'))
    x__grabdemo = 0;
    x__rundemo = 0;
    x__verbose = x__batch;
  elseif (strcmp (x__flag, 'quiet'))
    x__grabdemo = 0;
    x__rundemo = 0;
    x__verbose = 0;
  elseif (strcmp (x__flag, 'verbose'))
    x__grabdemo = 0;
    x__rundemo = 1;
    x__verbose = 1;
  elseif (strcmp (x__flag, 'grabdemo'))
    x__grabdemo = 1;
    x__rundemo = 0;
    x__verbose = 0;
    x__demo_code = '';
    x__demo_idx = [];
  elseif (strcmp (x__flag, 'explain'))
    fprintf (x__fid, '%% %s new test file\n', x__signal_file);
    fprintf (x__fid, '%% %s no tests in file\n', x__signal_empty);
    fprintf (x__fid, '%% %s test had an unexpected result\n', x__signal_fail);
    fprintf (x__fid, '%% %s code for the test\n', x__signal_block);
    fprintf (x__fid, '%% Search for the unexpected results in the file\n');
    fprintf (x__fid, '%% then page back to find the file name which caused it.\n');
    fprintf (x__fid, '%% The result may be an unexpected failure (in which\n');
    fprintf (x__fid, '%% case an error will be reported) or an unexpected\n');
    fprintf (x__fid, '%% success (in which case no error will be reported).\n');
    fflush (x__fid);
    if (x__close_fid)
      fclose(x__fid);
    end
    return;
  else
    error ('test: unknown flag ''%s''', x__flag);
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
    if (x__grabdemo)
      x__ret1 = '';
      x__ret2 = [];
    else
      if (exist (x__name) == 3)
        fprintf (x__fid, '%s%s source code with tests for dynamically linked function not found\n', x__signal_empty, x__name);
      else
        fprintf (x__fid, '%s%s does not exist in path\n', x__signal_empty, x__name);
      end
      fflush (x__fid);
      if (nargout > 0)
        x__ret1 = 0; x__ret2 = 0;
      end
    end
    if (x__close_fid)
      fclose(x__fid);
    end
    return;
  end

  % Grab the test code from the file.
  x__body = x__extract_test_code (x__file);

  if (isempty (x__body))
    if (x__grabdemo)
      x__ret1 = '';
      x__ret2 = [];
    else
      fprintf (x__fid, '%s%s has no tests available\n', x__signal_empty, x__file);
      fflush (x__fid);
      if (nargout > 0)
        x__ret1 = 0; x__ret2 = 0;
      end
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
    disp ([x__signal_file, x__file]);
  end

  % Assume all tests will pass.
  x__all_success = 1;

  % Process each block separately, initially with no shared variables.
  x__tests = 0; x__successes = 0;
  x__shared = ' ';
  x__shared_r = ' ';
  x__clear = '';
  for x__i = 1:length(x__blockidx)-1

    % Extract the block.
    x__block = x__body(x__blockidx(x__i):x__blockidx(x__i+1)-2);

    % Let the user/logfile know what is happening.
    if (x__verbose)
      fprintf (x__fid, '%s%s\n', x__signal_block, x__block);
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

%%% DEMO

    % If in x__grabdemo mode, then don't process any other block type.
    % So that the other block types don't have to worry about
    % this x__grabdemo mode, the demo block processor grabs all block
    % types and skips those which aren't demo blocks.

    x__isdemo = strcmp (x__type, 'demo');
    if (x__grabdemo || x__isdemo)
      x__istest = 0;

      if (x__grabdemo && x__isdemo)
        if (isempty(x__demo_code))
          x__demo_code = x__code;
          x__demo_idx = [1, length(x__demo_code)+1];
        else
          x__demo_code = [x__demo_code, x__code];
          x__demo_idx = [x__demo_idx, length(x__demo_code)+1];
        end

      elseif (x__rundemo && x__isdemo)
        try
          % process the code in an environment without variables
          eval (sprintf ('function x__testx__()\n%s\nend', x__code));
          x__testx__;
          input ('Press <enter> to continue: ', 's');
        catch
          x__success = 0;
          x__msg = sprintf ('%sdemo failed\n%s',  x__signal_fail, lasterr ());
        end
        clear x__testx__;

      end
      % Code already processed.
      x__code = '';

%%% SHARED

    elseif (strcmp (x__type, 'shared'))
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

      %       % Strip comments off the variables.
      %       x__idx = find (x__vars == '%' | x__vars == '%%');
      %       if (~ isempty (x__idx))
      %         x__vars = x__vars(1:x__idx(1)-1);
      %       end

      % Assign default values to variables.
      try
        x__vars = deblank (x__vars);
        if (~ isempty (x__vars))
          eval ([strrep(x__vars, ',', '=[];'), '=[];']);
          x__shared = x__vars;
          x__shared_r = ['[ ', x__vars, '] = '];
        else
          x__shared = ' ';
          x__shared_r = ' ';
        end
      catch
        % Couldn't declare, so don't initialize.
        x__code = '';
        x__success = 0;
        x__msg = sprintf ('%sshared variable initialization failed\n', ...
                         x__signal_fail);
      end

      % Clear shared function definitions.
      eval (x__clear, '');
      x__clear = '';

      % Initialization code will be evaluated below.

%%% FUNCTION

    elseif (strcmp (x__type, 'function'))
      x__istest = 0;
      persistent x__fn
      x__fn = 0;
      x__name_position = function_name (x__block);
      if (isempty (x__name_position))
        x__success = 0;
        x__msg = sprintf ('%stest failed: missing function name\n', ...
                         x__signal_fail);
      else
        x__name = x__block(x__name_position(1):x__name_position(2));
        x__code = x__block;
        try
          eval(x__code); % Define the function
          x__clear = sprintf ('%sclear %s;\n', x__clear, x__name);
        catch
          x__success = 0;
          x__msg = sprintf ('%stest failed: syntax error\n%s', ...
                           x__signal_fail, lasterr ());
        end
      end
      x__code = '';

%%% ENDFUNCTION

    elseif (strcmp (x__type, 'end'))
      % end simply declares the end of a previous function block.
      % There is no processing to be done here, just skip to next block.
      x__istest = 0;
      x__code = '';

%%% ASSERT/FAIL

    elseif (strcmp (x__type, 'assert') || strcmp (x__type, 'fail'))
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
      try
        %eval (sprintf ('function x__testx__(%s)\n%s\nend', ...
        %               x__shared, x__code));
      catch
        x__success = 0;
        x__msg = sprintf ('%stest failed: syntax error\n%s', ...
                         x__signal_fail, lasterr ());
      end

      if (x__success)
        x__success = 0;
        %x__warnstate = warning ('query', 'quiet');
        %warning ('on', 'quiet');
        try
          %eval (sprintf ('x__testx__(%s);', x__shared));
          eval(x__code);
          if (~ x__warning)
            x__msg = sprintf ('%sexpected %s but got no error\n', ...
                             x__signal_fail, x__patstr);
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
                             x__signal_fail, x__patstr);
            elseif (x__mismatch)
              x__msg = sprintf ('%sexpected %s but got %s\n', ...
                               x__signal_fail, x__patstr, x__err);
            else
              x__success = 1;
            end
          end

        catch
          if (~ isempty (x__id))
            [ignore_arg, x__err] = lasterr;
            x__mismatch =~strcmp (x__err, x__id);
          else
            x__err = trimerr (lasterr, 'error');
            x__mismatch = isempty (regexp (x__err, x__pattern, 'once'));
          end
          %warning (x__warnstate.state, 'quiet');
          if (x__warning)
            x__msg = sprintf ('%sexpected warning %s but got error %s\n', ...
                             x__signal_fail, x__patstr, x__err);
          elseif (x__mismatch)
            x__msg = sprintf ('%sexpected %s but got %s\n', ...
                             x__signal_fail, x__patstr, x__err);
          else
            x__success = 1;
          end
        end
        clear x__testx__;
      end
      % Code already processed.
      x__code = '';

%%% TESTIF

    elseif (strcmp (x__type, 'testif'))
      x__e = regexp (x__code, '.$', 'lineanchors', 'once');
      % Strip comment any comment from testif line before looking for features
      x__feat_line = strtok (x__code(1:x__e), '%%%'); 
      x__feat = regexp (x__feat_line, '\w+', 'match');
      x__have_feat = strfind (octave_config_info ('DEFS'), x__feat); 
      if (any (cellfun ('isempty', x__have_feat)))
        x__xskip = x__xskip + 1;
        x__istest = 0;
        x__code = ''; % Skip the code.
        x__msg = sprintf ('%sskipped test\n', x__signal_skip);
      else
        x__istest = 1;
        x__code = x__code(x__e + 1 : end);
      end

%%% TEST

    elseif (strcmp (x__type, 'test') || strcmp (x__type, 'xtest'))
      x__istest = 1;
      % Code will be evaluated below.

%%% Comment block.

    elseif (strcmp (x__block(1:1), '%%'))
      x__istest = 0;
      x__code = ''; % skip the code

%%% Unknown block.

    else
      x__istest = 1;
      x__success = 0;
      x__msg = sprintf ('%sunknown test type!\n', x__signal_fail);
      x__code = ''; % skip the code
    end

    % evaluate code for test, shared, and assert.
    if (~ isempty(x__code))
      try
        % FIXME: need to check for embedded test functions, which cause
        % segfaults, until issues with subfunctions in functions are resolved.
        embed_func = regexp (x__code, '^\s*function ', 'once', 'lineanchors');
        if (isempty (embed_func))
          %eval (sprintf ('function %sx__testx__(%s)\n%s\nend', ...
          %               x__shared_r,x__shared, x__code));
          %eval (sprintf ('%sx__testx__(%s);', x__shared_r, x__shared));
          eval(x__code); % This 
        else
          error (['Functions embedded in %!test blocks are not allowed.\n', ...
                  'Use the %!function/%!end syntax instead to define shared functions for testing.\n']);
        end
      catch
        if (strcmp (x__type, 'xtest'))
           x__msg = sprintf ('%sknown failure\n%s', x__signal_fail, lasterr ());
           x__xfail = x__xfail + 1;
        else
           x__msg = sprintf ('%stest failed\n%s', x__signal_fail, lasterr ());
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
        fprintf (x__fid, '%s%s\n', x__signal_block, x__block);
        fflush (x__fid);
      end
      fprintf(x__fid, '%s', x__msg);
      fprintf(x__fid, '%s', sprintf('\n'));
      fflush (x__fid);
%       % Show the variable context.
%       if (~ strcmp (x__type, 'error') && ~strcmp (x__type, 'testif') ...
%           && ~all (x__shared == ' '))
%         fprintf(x__fid, '%s', 'shared variables ');
%         eval (sprintf ('disp(x__fid,bundle(%s));', x__shared));
%         fflush (x__fid);
%       end
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
  eval (x__clear, '');

  if (nargout == 0)
    if (x__tests || x__xfail || x__xskip)
      if (x__xfail)
        fprintf ('PASSES %d out of %d tests (%d expected failures)\n', ...
                x__successes, x__tests, x__xfail);
      else
        fprintf ('PASSES %d out of %d tests\n', x__successes, x__tests);
      end
      if (x__xskip)
        fprintf ('Skipped %d tests due to missing features\n', x__xskip);
      end
    else
      fprintf ('%s%s has no tests available\n', x__signal_empty, x__file);
    end
  elseif (x__grabdemo)
    x__ret1 = x__demo_code;
    x__ret2 = x__demo_idx;
  elseif (nargout == 1)
    x__ret1 = x__all_success;
  else
    x__ret1 = x__successes;
    x__ret2 = x__tests;
    x__ret3 = x__xfail;
    x__ret4 = x__xskip;
  end
end

% Create structure with fieldnames the name of the input variables.
function s = varstruct (varargin)
  for i = 1:nargin
    s.(deblank (argn(i,:))) = varargin{i};
  end
end

% Find [start,end] of fn in 'function [a,b] = fn'.
function pos = function_name (def)
  pos = [];

  % Find the end of the name.
  right = find (def == '(', 1);
  if (isempty (right))
    return;
  end
  right = find (def(1:right-1) ~= ' ', 1, 'last');

  % Find the beginning of the name.
  left = max ([find(def(1:right)==' ', 1, 'last'), ...
               find(def(1:right)=='=', 1, 'last')]);
  if (isempty (left))
    return;
  end
  left = left + 1;

  % Return the end points of the name.
  pos = [left, right];
end

% Strip <pattern> from '<pattern> code'.
% Also handles 'id=ID code'
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
end

% Strip '.*prefix:' from '.*prefix: msg\n' and strip trailing blanks.
function msg = trimerr (msg, prefix)
  idx = index (msg, [prefix, ':']);
  if (idx > 0)
    msg(1:idx+length(prefix)) = [];
  end
  msg = trimleft (deblank (msg));
end

% Strip leading blanks from string.
function str = trimleft (str)
  idx = find (isspace (str));
  leading = find (idx == 1:length(idx));
  if (~ isempty (leading))
    str = str(leading(end)+1:end);
  end
end

% Make a structure out of the named variables
% (based on Etienne Grossmann's tar function).
function s = bundle (varargin)
  for i = 1:nargin
    %s.(deblank (argn(i,:))) = varargin{i};
    s.(inputname(i)) =  varargin{i};
  end
end

function body = x__extract_test_code (nm)
  fid = fopen (nm, 'rt');
  body = [];
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
end

%%% Test for test for missing features
% !testif OCTAVE_SOURCE
% ! % This test should be run
% ! assert (true);

%%% Disable this test to avoid spurious skipped test for 'make check'
% !testif HAVE_FOOBAR
% ! % missing feature. Fail if this test is run
% ! error('Failed missing feature test');

%%% Test for a known failure
% !xtest error('This test is known to fail')

%%% example from toeplitz
%!shared msg1,msg2
%! msg1='C must be a vector';
%! msg2='C and R must be vectors';
%!fail ('toeplitz([])', msg1);
%!fail ('toeplitz([1,2;3,4])', msg1);
%!fail ('toeplitz([1,2],[])', msg2);
%!fail ('toeplitz([1,2],[1,2;3,4])', msg2);
%!fail ('toeplitz ([1,2;3,4],[1,2])', msg2);
% !fail ('toeplitz','usage: toeplitz'); % usage doesn't generate an error
% !fail ('toeplitz(1, 2, 3)', 'usage: toeplitz');
%!test  assert (toeplitz ([1,2,3], [1,4]), [1,4; 2,1; 3,2]);
%!demo  toeplitz ([1,2,3,4],[1,5,6])

%%% example from kron
%!%error kron  % FIXME suppress these until we can handle output
%!%error kron(1,2,3)
%!test assert (isempty (kron ([], rand(3, 4))))
%!test assert (isempty (kron (rand (3, 4), [])))
%!test assert (isempty (kron ([], [])))
%!shared A, B
%!test
%! A = [1, 2, 3; 4, 5, 6];
%! B = [1, -1; 2, -2];
%!assert (size (kron (zeros (3, 0), A)), [ 3*rows(A), 0 ])
%!assert (size (kron (zeros (0, 3), A)), [ 0, 3*columns(A) ])
%!assert (size (kron (A, zeros (3, 0))), [ 3*rows(A), 0 ])
%!assert (size (kron (A, zeros (0, 3))), [ 0, 3*columns(A) ])
%!assert (kron (pi, e), pi*e)
%!assert (kron (pi, A), pi*A)
%!assert (kron (A, e), e*A)
%!assert (kron ([1, 2, 3], A), [ A, 2*A, 3*A ])
%!assert (kron ([1; 2; 3], A), [ A; 2*A; 3*A ])
%!assert (kron ([1, 2; 3, 4], A), [ A, 2*A; 3*A, 4*A ])
%!test
%! res = [1,-1,2,-2,3,-3; 2,-2,4,-4,6,-6; 4,-4,5,-5,6,-6; 8,-8,10,-10,12,-12];
%! assert (kron (A, B), res)

%%% an extended demo from specgram
%!%demo
%! % Speech spectrogram
%! [x, Fs] = auload(file_in_loadpath('sample.wav')); % audio file
%! step = fix(5*Fs/1000);     % one spectral slice every 5 ms
%! window = fix(40*Fs/1000);  % 40 ms data window
%! fftn = 2^nextpow2(window); % next highest power of 2
%! [S, f, t] = specgram(x, fftn, Fs, window, window-step);
%! S = abs(S(2:fftn*4000/Fs,:)); % magnitude in range 0<f<=4000 Hz.
%! S = S/max(max(S));         % normalize magnitude so that max is 0 dB.
%! S = max(S, 10^(-40/10));   % clip below -40 dB.
%! S = min(S, 10^(-3/10));    % clip above -3 dB.
%! imagesc(flipud(20*log10(S)), 1);
%! % you should now see a spectrogram in the image window


%%% now test test itself

%!% usage and error testing
% !fail ('test','usage.*test')           % no args, generates usage()
% !fail ('test(1,2,3,4)','usage.*test')  % too many args, generates usage()
%!fail ('test('test', 'bogus')','unknown flag')      % incorrect args
%!fail ('garbage','garbage.*undefined')  % usage on nonexistent function should be

%!error test                     % no args, generates usage()
%!error test(1,2,3,4)            % too many args, generates usage()
%!error <unknown flag> test('test', 'bogus');  % incorrect args, generates error()
%!error <garbage' undefined> garbage           % usage on nonexistent function should be

%!error test('test', 'bogus');           % test without pattern

%!test
%! lastwarn();            % clear last warning just in case

%!warning <warning message> warning('warning message');

%!% test of shared variables
%!shared a                % create a shared variable
%!test   a=3;             % assign to a shared variable
%!test   assert(a,3)      % variable should equal 3
%!shared b,c              % replace shared variables
%!test assert (~exist('a'));   % a no longer exists
%!test assert (isempty(b));    % variables start off empty
%!shared a,b,c            % recreate a shared variable
%!test assert (isempty(a));    % value is empty even if it had a previous value
%!test a=1; b=2; c=3;   % give values to all variables
%!test assert ([a,b,c],[1,2,3]); % test all of them together
%!test c=6;             % update a value
%!test assert([a, b, c],[1, 2, 6]); % show that the update sticks
%!shared                    % clear all shared variables
%!test assert(~exist('a'))  % show that they are cleared
%!shared a,b,c              % support for initializer shorthand
%! a=1; b=2; c=4;

%!function x = x__test_a(y)
%! x = 2*y;
%!end
%!assert(x__test_a(2),4);       % Test a test function

%!function x__test_a (y)
%! x = 2*y;
%!end
%!test
%! x__test_a(2);                % Test a test function with no return value

%!function [x,z] = x__test_a (y)
%! x = 2*y;
%! z = 3*y;
%!end
%!test                   % Test a test function with multiple returns
%! [x,z] = x__test_a(3);
%! assert(x,6);
%! assert(z,9);

%!% test of assert block
%!assert (isempty([]))      % support for test assert shorthand

%!% demo blocks
%!demo                   % multiline demo block
%! t=[0:0.01:2*pi]; x=sin(t);
%! plot(t,x);
%! % you should now see a sine wave in your figure window
%!demo a=3               % single line demo blocks work too

%!% this is a comment block. it can contain anything.
%!%
%! it is the '%%' as the block type that makes it a comment
%! and it  stays as a comment even through continuation lines
%! which means that it works well with commenting out whole tests

% !% failure tests.  All the following should fail. These tests should
% !% be disabled unless you are developing test() since users don't
% !% like to be presented with expected failures.  I use % ! to disable.
% !test   error('---------Failure tests.  Use test(''test'',''verbose'',1)');
% !test   assert([a,b,c],[1,3,6]);   % variables have wrong values
% !bogus                     % unknown block type
% !error  toeplitz([1,2,3]); % correct usage
% !test   syntax errors)     % syntax errors fail properly
% !shared garbage in         % variables must be comma separated
% !error  syntax++error      % error test fails on syntax errors
% !error  'succeeds.';       % error test fails if code succeeds
% !error <wrong pattern> error('message')  % error pattern must match
% !demo   with syntax error  % syntax errors in demo fail properly
% !shared a,b,c
% !demo                      % shared variables not available in demo
% ! assert(exist('a'))
% !error
% ! test('/etc/passwd');
% ! test('nonexistent file');
% ! % These don't signal an error, so the test for an error fails. Note
% ! % that the call doesn't reference the current fid (it is unavailable),
% ! % so of course the informational message is not printed in the log.
