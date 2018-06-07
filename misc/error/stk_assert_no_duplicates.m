% STK_ASSERT_NO_DUPLICATES generates an error if there are duplicates

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function stk_assert_no_duplicates (x)

mnemonic = 'DuplicatedRows';

% Name of the input variable (if available)
boxname = inputname (1);
if isempty (boxname)
    boxname = 'input array';
end

% Pretend that the error has been thrown by the caller
stack = dbstack;  stack = stack(2:end);

% Detect duplicated rows
x = double (x);
n = size (x, 1);
y = unique (x, 'rows');
if size (y, 1) < n
    errmsg = sprintf ('%s has duplicated rows', boxname);
    stk_error (errmsg, mnemonic, stack);
end

end % function
