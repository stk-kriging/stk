% SUBSASGN [overloaded base function]

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
            
            [n, d] = size(x.data);
            L = length(idx(1).subs);
            
            if (d == 1) && ~((L == 1) || (L == 2))
                
                stk_error(['Illegal indexing for a univariate stk_dataframe' ...
                    'object.'], 'IllegalIndexing');
                
            elseif (d > 1) && (L ~= 2)
                
                stk_error(['multivariate stk_dataframe objects only support ' ...
                    'matrix-style indexing.'], 'IllegalIndexing');
                
            else % ok, legal indexing
                            
                val = double(val);
                
                if ~isempty(val)

                    x.data = subsasgn(x.data, idx, val);
                    
                    [n1, d1] = size(x.data);
                    if (n1 > n) && ~isempty(x.rownames) 
                        x.rownames = vertcat(x.rownames, repmat({''}, n1 - n, 1));
                    end
                    if (d1 > d) && ~isempty(x.vnames)
                        x.vnames = horzcat(x.vnames, repmat({''}, 1, d1 - d));
                    end
                    
                else % assignment rhs is empty
                    
                    idx_row = idx(1).subs{1};                    
                    
                    if L > 1
                        idx_col = idx(1).subs{2};
                    else
                        idx_col = 1;
                    end
                    
                    remove_columns = (strcmp(idx_row, ':') ...
                        || ((n == 1) && isequal(idx_row, 1)));
                    remove_rows = (strcmp(idx_col, ':') ...
                        || ((d == 1) && isequal(idx_col, 1)));
                    
                    if ~xor(remove_columns, remove_rows)
                        
                        stk_error('Illegal indexing.', 'IllegalIndexing');
                        
                    elseif remove_columns
                        
                        x.data(:, idx_col) = [];
                        if ~isempty(x.vnames)
                            x.vnames(idx_col) = [];
                        end
                        
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
        
        if length(idx) > 1
            val = subsasgn(get(x, idx(1).subs), idx(2:end), val);
        end
        x = set(x, idx(1).subs, val);
        
end

end % function subsasgn

%!shared x s t data
%! x = stk_dataframe(rand(3, 2));
%! s = {'a'; 'b'; 'c'};
%! t = {'xx' 'yy'};

%!test
%! x.rownames = s;
%! assert (isequal(get(x, 'rownames'), s))

%!test
%! x.colnames = t;
%! assert (isequal(get(x, 'rownames'), s))
%! assert (isequal(get(x, 'colnames'), t))

%!test
%! x.rownames{2} = 'dudule';
%! assert (isequal(get(x, 'rownames'), {'a'; 'dudule'; 'c'}))
%! assert (isequal(get(x, 'colnames'), t))

%!test
%! x.colnames{1} = 'martha';
%! assert (isequal(get(x, 'rownames'), {'a'; 'dudule'; 'c'}))
%! assert (isequal(get(x, 'colnames'), {'martha' 'yy'}))

% %!error x.colnames{1} = 'yy'
% %!error x.colnames = {'xx' 'xx'}

%!test
%! data = stk_dataframe(zeros(3, 2), {'x1' 'x2'});
%! u = rand(3, 1); data.x2 = u;
%! assert (isequal(double(data), [zeros(3, 1) u]))

%!test
%! data = stk_dataframe(zeros(3, 2), {'x1' 'x2'});
%! data.x2(3) = 27;
%! assert (isequal(double(data), [0 0; 0 0; 0 27]))

%!error data.toto = rand(3, 1);

%!shared x
%! x = stk_dataframe(reshape(1:12, 4, 3));

%!test
%! x(:, 2) = [];
%! assert (isequal(size(x), [4 2]))
%! assert (isequal(double(x), [1 9; 2 10; 3 11; 4 12]))

%!test
%! x(2, :) = [];
%! assert (isequal(size(x), [3 2]))
%! assert (isequal(double(x), [1 9; 3 11; 4 12]))

%!test
%! x.rownames = {'a'; 'b'; 'c'};
%! x(2, :) = [];
%! assert (isequal(size(x), [2 2]))
%! assert (isequal(double(x), [1 9; 4 12]))
%! assert (isequal(x.rownames, {'a'; 'c'}))

%!test
%! x(1, 2) = 11;
%! assert (isequal(size(x), [2 2]))
%! assert (isequal(double(x), [1 11; 4 12]))

%!error x{1} = 2;
%!error x(1, 2) = [];
%!error x(:, :) = [];
%!error x(1, 2).a = 3;
%!error x(3) = 2;

%--- tests with a univariate dataframe ----------------------------------------

%!shared x
%! x = stk_dataframe((1:5)');

% linear indexing is allowed for univariate dataframes
%!test x(2) = 0;   assert (isequal(double(x), [1; 0; 3; 4; 5]));
%!test x(3) = [];  assert (isequal(double(x), [1; 0; 4; 5]));

% matrix-style indexing also
%!test x(3, 1) = 0;  assert (isequal(double(x), [1; 0; 0; 5]));

% three indices is not allowed (even if the third is one...)
%!error x(3, 1, 1) = 297;

%!test % create a new row and a new column through subsasgn()
%! x = stk_dataframe(rand(5, 2)); x(6, 3) = 7; disp(x)
%! assert(isequal(size(x), [6, 3]));
