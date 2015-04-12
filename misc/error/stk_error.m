% STK_ERROR throws an STK error with a good-looking error identifier.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

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

function stk_error (errmsg, mnemonic, stack)

% second component of error identifier = name of calling function
% (unless stk_error has been called directly from the base workspace)
if nargin < 3,
    stack = dbstack ();
    if length (stack) == 1,
        caller = 'BaseWorkspace';
    else
        % pretend that the error has been thrown by the caller
        stack = stack(2:end);
        % and get caller name to form the error identifier
        caller = stack(1).name;
    end
else
    % if a "stack" has been provided by the user, we use it without asking
    % questions (if it's a struct)
    if ~ isstruct (stack) || ~ isfield (stack, 'name'),
        % We will throw an error, but not the one we were requested to!
        errmsg = 'Argument "stack" should be a valid stack structure.';
        mnemonic = 'InvalidArgument';
        stack = dbstack ();
    end
    caller = stack(1).name;
end

% keep only subfunction name (Octave)
gt_pos = strfind (caller, '>');
if ~ isempty (gt_pos),
    caller = caller((gt_pos + 1):end);
end

% construct the error structure
errstruct = struct (...
    'message', errmsg, ...
    'identifier', sprintf ('STK:%s:%s', caller, mnemonic), ...
    'stack', stack);

error (errstruct);

end % function stk_error


%!shared errmsg, mnemonic, badstack
%!  errmsg = 'Go ahead, make my day.';
%!  mnemonic = 'ClintEastwood';
%!  badstack = 0; % not a valid stack structure

% Valid use of stk_error
%!error <make my day> stk_error(errmsg, mnemonic);

% Use of an incorrect stack structure
%!error <stack structure> stk_error (errmsg, mnemonic, badstack);
%!error id=STK:stk_error:InvalidArgument stk_error (errmsg, mnemonic, badstack);
