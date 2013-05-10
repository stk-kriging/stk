% INDEX finds the first (or last) occurence of one string within another.
%
% CALL: index(S, T)
% CALL: index(S, T, "first")
%   Returns the position of the first occurrence of the string T in the
%   string S, or 0 if no occurrence is found. S may also be a cell array
%   of strings.
%
% CALL: index(S, T, "last")
%   Returns the position of the last occurrence.
%
% EXAMPLES:
%   index("Teststring", "t")            returns 4
%   index('Teststring', 't', 'last')    returns 6
%   index({'Hello', 'Toto'}, 'o')        returns [5 2]
%
% SEE ALSO:
%   strfind

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
%    This file has been adapted from index.m in Octave 3.6.2, distributed
%    under the GNU General Public Licence version 3 (GPLv3). The original
%    copyright notice and authorship statement were as follows:
%
%        Copyright (C) 1996-2012 Kurt Hornik
%
%        Author: Kurt Hornik <Kurt.Hornik@wu-wien.ac.at>
%        Adapted-By: jwe

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

function n = index (s, t, direction)

if nargin < 3, direction = 'first'; end

if ischar(s)
    if size(s, 1) > 1
        s = cellstr (s);  % Handle string arrays by conversion to cellstr
    end
elseif ~iscellstr(s)
    error ('index: S must be a string, string array, or cellstr');
end

f = strfind (s, t);
if (isempty (f))
    f = 0;
elseif (iscell (f))
    f(cellfun ('isempty', f)) = {0};
end

direction = lower (direction);

if (strcmp (direction, 'first'))
    if (iscell (f))
        n = cellfun (@min, f);
    else
        n = f(1);
    end
elseif (strcmp (direction, 'last'))
    if (iscell (f))
        n = cellfun (@max, f);
    else
        n = f(end);
    end
else
    error ('index: DIRECTION must be either "first" or "last"');
end

end


%!assert (index ('foobarbaz', 'b') == 4 && index ('foobarbaz', 'z') == 9);

%!assert (isequal(index('astringbstringcstring', 's'), 2))
%!assert (isequal(index('astringbstringcstring', 'st'), 2))
%!assert (isequal(index('astringbstringcstring', 'str'), 2))
%!assert (isequal(index('astringbstringcstring', 'string'), 2))
%!assert (isequal(index('abc---', 'abc+++'), 0))

%% test everything out in reverse
%!assert (isequal(index('astringbstringcstring', 's', 'last'), 16))
%!assert (isequal(index('astringbstringcstring', 'st', 'last'), 16))
%!assert (isequal(index('astringbstringcstring', 'str', 'last'), 16))
%!assert (isequal(index('astringbstringcstring', 'string', 'last'), 16))
%!assert (isequal(index('abc---', 'abc+++', 'last'), 0))

%!test
%! str = char ('Hello', 'World', 'Goodbye', 'World');
%! assert(isequal(index(str, 'o'), [5; 2; 2; 2]));
%! assert(isequal(index(str, 'o', 'last'), [5; 2; 3; 2]));
%! str = cellstr (str);
%! assert(isequal(index(str, 'o'), [5; 2; 2; 2]));
%! assert(isequal(index(str, 'o', 'last'), [5; 2; 3; 2]));

%% Test input validation
%!error index ()
%!error index ('a')
%!error index ('a', 'b', 'first', 'd')
%!error index (1, 'bar')
%!error index ('foo', 'bar', 3)
