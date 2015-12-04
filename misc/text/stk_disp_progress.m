% STK_DISP_PROGRESS ...
%
% Example:
%
%    for i = 1:1000,
%       stk_disp_progress ('toto ', i, 1000);
%    end
%
% See also: waitbar

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Authors:  Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>
%              Julien Bect       <julien.bect@centralesupelec.fr>

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

function stk_disp_progress (msg, n, N)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if ~ ((n > 0) && (n <= N))
    stk_error ('n should be between 1 and N', 'InvalidArgument');
end

persistent revmsg

if n == 1
    revmsg = [];
end

% Print current progress message
msg = sprintf (msg, n, N);
fprintf ([revmsg, msg]);

% Prepare for erasing next time
revmsg = repmat (sprintf ('\b'), 1, length (msg));

if n == N
    fprintf ('\n');
end

end % function


%!error stk_disp_progress ('toto ', 0, 1);
%!test  stk_disp_progress ('toto ', 1, 1);
%!error stk_disp_progress ('toto ', 2, 1);

%!test
%! stk_disp_progress ('toto ', 1, 2);
%! stk_disp_progress ('toto ', 2, 2);
