% STK_MLINT_ALL

% Copyright Notice
%
%    Copyright (C) 2021 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function [m, b_ok] = stk_mlint_all (root)

if nargin == 0
    root = fileparts (fileparts (mfilename ('fullpath')));
end

m = stk_mlint_all_ (root);

% Linter messages that trigger a global error
% (this list will be growing progressively)
critical_errors = {'ISCLSTR', 'ISMT', 'MINV', 'MSNU', 'NOPAR', 'NOPAR2', ...
    'NOPRT', 'RESWD', 'STREMP', 'STRIN', 'STTOK', 'TRYNC'};

b_ok = ~ any (ismember ({m.id}, critical_errors));

% FIXME: Display critical errors separately
fprintf ('\n\nSUMMARY:\n')
[msg, ~, ic] = unique ({m.id});
for k = 1:(length (msg))
    fprintf ('% 3d %s\n', sum (ic == k), msg{k});
end

end % function


function m = stk_mlint_all_ (root)

m = [];

s = dir (root);
for i = 1:(length (s))

    fn = fullfile (root, s(i).name);

    if s(i).isdir  % Process subdirectories recursively
        if s(i).name(1) == '.'
            fprintf ('Skipping directory %s\n', fn);
            continue
        end % if

        fprintf ('Processing directory %s ...\n', fn);
        m_ = stk_mlint_all_ (fn);
        fprintf ('Directory %s processed: %d messages\n', fn, length (m_));

    else  % Process M-files

        if (length (s(i).name) < 2) ...
                || (~ strcmp (s(i).name(end-1:end), '.m'))
            fprintf ('Skipping file %s\n', fn);
            continue
        end % if

        fprintf ('Processing file %s ...\n', fn);
        m_ = checkcode (fn, '-struct', '-id');
        [m_.file] = deal (fn);

    end % if

    if isempty (m)
        m = m_;
    else
        m = [m; m_];  %#ok<AGROW>
    end

end % for

end % function
