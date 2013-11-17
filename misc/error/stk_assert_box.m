% STK_ASSERT_BOX ... [FIXME: missing documentation]

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function stk_assert_box (box, dim)

mnemonic = 'InvalidBox';

% Name of the input variable (if available)
boxname = inputname (1);
if isempty (boxname),
    boxname = 'box';
end

% Pretend that the error has been thrown by the caller
stack = dbstack;  stack = stack(2:end);

% Check that box is a numeric matrix (the behaviour of ismatrix is inconsistent
% between Matlab and Octave for arrays with more than two dimensions...)
ismatrix = isnumeric (box) && (length( size (box)) == 2);
if ~ ismatrix,
    errmsg = sprintf ('%s is not a numeric matrix.', boxname);
    stk_error (errmsg, mnemonic, stack);
end

[n, d] = size (box);
if n ~= 2,
    errmsg = sprintf ('%s should have two rows, not more, not less.', boxname);
    stk_error (errmsg, mnemonic, stack);
end

if d == 0,
    errmsg = sprintf ('%s should have at least one column.', boxname);
    stk_error (errmsg, mnemonic, stack);
end

if (nargin == 2) && (d ~= dim)
    errmsg = sprintf ('%s should exactly %d columns.', boxname, dim);
    stk_error (errmsg, mnemonic, stack);
end

if any (isnan (box)),
    errmsg = sprintf ('%s should at least one column.', boxname);
    stk_error (errmsg, mnemonic, stack);
end

if any (box(1, :) > box(2, :)),
    errmsg = sprintf ('%s has invalid boundaries.', boxname);
    stk_error (errmsg, mnemonic, stack);
end

end % function stk_assert_box
