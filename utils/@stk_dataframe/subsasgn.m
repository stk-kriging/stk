% SUBSASGN [FIXME: missing doc...]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function x = subsasgn(x, idx, val)

switch idx(1).type
    
    case '()'
        
        if length(idx) ~= 1
            
            stk_error('Illegal indexing.', 'IllegalIndexing');
            
        else % ok, only one level of indexing
            
            if length(idx(1).subs) ~= 2
                
                errmsg = 'stk_dataframe objects only support matrix-style indexing.';
                stk_error(errmsg, 'IllegalIndexing');

            else % ok, matrix-style indexing
                
                val = double(val);
                
                if ~isempty(val)
                    
                    x.data = subsasgn(x.data, idx, val);
                    
                else % assignment rhs is empty
                    
                    idx_row = idx(1).subs{1};
                    remove_columns = strcmp(idx_row, ':');
                    
                    idx_col = idx(1).subs{2};
                    remove_rows = strcmp(idx_col, ':');
                    
                    if ~xor(remove_columns, remove_rows)
                        
                        stk_error('Illegal indexing.', 'IllegalIndexing');
                        
                    elseif remove_columns
                        
                        x.data(:, idx_col) = [];
                        x.vnames(idx_col) = [];
                        
                    else % remove_rows
                        
                        x.data(idx_row, :) = [];
                        if ~isempty(x.rownames),
                            x.rownames(idx_row) = [];
                        end
                        
                    end
                end
            end            
        end
        
    case '{}'
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        
        switch idx(1).subs,
            
            case 'rownames',
                if length(idx) > 1
                    val = subsasgn(stk_get_rownames(x), idx(2:end), val);
                end
                x = stk_set_rownames(x, val);
                
            case 'colnames',
                if length(idx) > 1
                    val = subsasgn(stk_get_colnames(x), idx(2:end), val);
                end
                x = stk_set_colnames(x, val);
                
            otherwise,
                b = get_column_indicator(x, idx(1).subs);
                val = double(val);
                if length(idx) > 1,
                    x.data(:, b) = subsasgn(x.data(:, b), idx(2:end), val);
                else
                    x.data(:, b) = val;
                end
                
        end % switch
        
end

end % function subsasgn

%!shared x s t data
%! x = stk_dataframe(rand(3, 2));
%! s = {'a'; 'b'; 'c'};
%! t = {'xx' 'yy'};

%!test
%! x.rownames = s;
%! assert (stk_isvalid (x))
%! assert (isequal(stk_get_rownames(x), s))

%!test
%! x.colnames = t;
%! assert (stk_isvalid (x))
%! assert (isequal(stk_get_rownames(x), s))
%! assert (isequal(stk_get_colnames(x), t))

%!test
%! x.rownames{2} = 'dudule';
%! assert (stk_isvalid (x))
%! assert (isequal(stk_get_rownames(x), {'a'; 'dudule'; 'c'}))
%! assert (isequal(stk_get_colnames(x), t))

%!test
%! x.colnames{1} = 'martha';
%! assert (stk_isvalid (x))
%! assert (isequal(stk_get_rownames(x), {'a'; 'dudule'; 'c'}))
%! assert (isequal(stk_get_colnames(x), {'martha' 'yy'}))

%!error x.colnames{1} = 'yy'
%!error x.colnames = {'xx' 'xx'}

%!test
%! data = stk_dataframe(zeros(3, 2));
%! u = rand(3, 1); data.x2 = u;
%! assert (stk_isvalid (data))
%! assert (isequal(double(data), [zeros(3, 1) u]))

%!test
%! data = stk_dataframe(zeros(3, 2));
%! data.x2(3) = 27;
%! assert (stk_isvalid (data))
%! assert (isequal(double(data), [0 0; 0 0; 0 27]))

%!error data.toto = rand(3, 1);

%!shared x
%! x = stk_dataframe(reshape(1:12, 4, 3));

%!test
%! x(:, 2) = [];
%! assert (stk_isvalid (x))
%! assert (isequal(size(x), [4 2]))
%! assert (isequal(double(x), [1 9; 2 10; 3 11; 4 12]))

%!test
%! x(2, :) = [];
%! assert (stk_isvalid (x))
%! assert (isequal(size(x), [3 2]))
%! assert (isequal(double(x), [1 9; 3 11; 4 12]))

%!test
%! x.rownames = {'a'; 'b'; 'c'};
%! x(2, :) = [];
%! assert (stk_isvalid (x))
%! assert (isequal(size(x), [2 2]))
%! assert (isequal(double(x), [1 9; 4 12]))
%! assert (isequal(x.rownames, {'a'; 'c'}))

%!test
%! x(1, 2) = 11;
%! assert (stk_isvalid (x))
%! assert (isequal(size(x), [2 2]))
%! assert (isequal(double(x), [1 11; 4 12]))

%!error x{1} = 2;
%!error x(1, 2) = [];
%!error x(:, :) = [];
%!error x(1, 2).a = 3;
%!error x(3) = 2;
