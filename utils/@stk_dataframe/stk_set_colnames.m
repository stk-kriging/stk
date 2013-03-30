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
    if ~((d == 1) && ischar(colnames))

        errmsg = 'colnames is expected to be a string or a cell-array of strings.';
        stk_error(errmsg, 'TypeMismatch');

    else % ok, we have a single column and a string for its name
        
        colnames = {colnames};

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
        
    elseif numel(colnames) ~= d
        
        errmsg = sprintf('colnames is expected to have d=%d elements.', d);
        stk_error(errmsg, 'IncorrectSize');
        
    else % ok, colnames has an appropriate size
        
        colnames = reshape(colnames, 1, d);
        
    end
end

if length(unique(colnames)) < d, % check for duplicated column names

    stk_error('Column names must be unique !', 'IncorrectArgument');

else
    
    % FIXME: check for reserved names; ...
    x.vnames = colnames;

end

end % function stk_set_colnames


%!shared x s t
%! x = stk_dataframe(rand(3, 2));
%! s = {'xx' 'yy'};

%!test
%! x = stk_set_colnames(x, s);
%! assert (isequal(stk_get_colnames(x), s))

%!error x = stk_set_colnames(x, {'x1' 'x1'})
%!error x = stk_set_colnames(x, [1 2])
%!error x = stk_set_colnames(x, {'xx' 'yy' 'zz'})
%!error x = stk_set_colnames(x, {'x1' 'x2'; 'x3' 'x4'})

%!test
%! x = stk_dataframe(rand(3, 1));
%! x = stk_set_colnames(x, 'xxx');
%! assert (isequal(stk_get_colnames(x), {'xxx'}))
