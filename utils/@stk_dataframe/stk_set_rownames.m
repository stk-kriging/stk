% STK_SET_ROWNAMES sets the row names of a dataframe

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

function x = stk_set_rownames(x, rownames)

if ~iscell(rownames)
    
    errmsg = 'rownames is expected to be a cell-array of strings.';
    stk_error(errmsg, 'TypeMismatch');

elseif isempty(rownames),
    
    x.rownames = {};
    
else
    
    n = size(x.data, 1);
    
    if length(rownames) ~= n
    
        errmsg = sprintf('rownames is expected to have length n=%d.', n);
        stk_error(errmsg, 'IncorrectSize');
    
    elseif numel(rownames) ~= n
        
        errmsg = sprintf('rownames is expected to have n=%d elements.', n);
        stk_error(errmsg, 'IncorrectSize');
    
    else
        
        rownames = reshape(rownames, n, 1);
        colnames_ = rownames(~cellfun(@isempty, rownames));
        
        % check for duplicated row names
        if length(unique(colnames_)) < length(colnames_)
       
            stk_error('Row names must be unique !', 'IncorrectArgument');
        
        else % ok, row names are unique
        
            x.rownames = rownames;

        end
    end
end

end % function stk_set_rownames


%!shared x s t
%! x = stk_dataframe(rand(3, 2));
%! s = {'a'; 'b'; 'c'};
%!test x = stk_set_rownames(x, s);
%!assert (isequal(stk_get_rownames(x), s))
%!error x = stk_set_rownames(x, {'a' 'b' 'a'})
%!error x = stk_set_rownames(x, [1 2 3])
%!error x = stk_set_rownames(x, {'a' 'b'})
%!error x = stk_set_rownames(x, {'a' 'b' 'c'; 'd' 'e' 'f'})
