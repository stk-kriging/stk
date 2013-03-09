% STK_SET_COLNAMES sets the column names of a dataframe

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function x = stk_set_colnames(x, colnames)

d = size(x.data, 2);

if ~iscell(colnames)
    if (d == 1) && ischar(colnames)
        colnames = {colnames};
    else
        errmsg = 'colnames is expected to be a string or a cell-array of strings.';
        stk_error(errmsg, 'TypeMismatch');
    end
end

if isempty(colnames)
    if d == 1,
        colnames = {'x'};
    else
        colnames = cell(1, d);
        for j = 1:d,
            colnames{j} = sprintf('x%d', j);
        end
    end
else
    if length(colnames) ~= d
        errmsg = sprintf('colnames is expected to have length d=%d.', d);
        stk_error(errmsg, 'IncorrectSize');
    end
    if numel(colnames) ~= d
        errmsg = sprintf('colnames is expected to have d=%d elements.', d);
        stk_error(errmsg, 'IncorrectSize');
    end
end

colnames = reshape(colnames, 1, d);

% check for duplicated column names
tmp = unique(colnames);
if length(tmp) < d,
    stk_error('Column names must be unique !', 'IncorrectArgument');
end

% FIXME: check for reserved names; ...
x.vnames = colnames;

end % function stk_set_colnames


%!shared x s t
%! x = stk_dataframe(rand(3, 2));
%! s = {'xx' 'yy'};
%!test x = stk_set_colnames(x, s);
%!assert (isequal(stk_get_colnames(x), s))
%!error x = stk_set_colnames(x, {'x1' 'x1'})
%!error x = stk_set_colnames(x, [1 2])
%!error x = stk_set_colnames(x, {'xx' 'yy' 'zz'})
%!error x = stk_set_colnames(x, {'x1' 'x2'; 'x3' 'x4'})
