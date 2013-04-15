% SUBSREF [overloaded base function]

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

function t = subsref(x, idx)

switch idx(1).type
    
    case '()'
        
        if length(idx) ~= 1
            
            stk_error('Illegal indexing.', 'IllegalIndexing');
            
        else % ok, only one level of indexing
            
            d = size(x, 2);
            L = length(idx(1).subs);
            
            if (d == 1) && ~((L == 1) || (L == 2))
                
                stk_error(['Illegal indexing for a univariate stk_dataframe' ...
                    'object.'], 'IllegalIndexing');
                
            elseif (d > 1) && (L ~= 2)
                
                stk_error(['multivariate stk_dataframe objects only support ' ...
                    'matrix-style indexing.'], 'IllegalIndexing');
                
            else % ok, legal indexing
                
                t = subsref(x.data, idx);
                
            end
            
        end
        
    case '{}'
        
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        
        switch idx(1).subs
            
            case 'rownames',
                t = stk_get_rownames(x);
                
            case 'colnames',
                t = stk_get_colnames(x);
                
            otherwise,
                b = get_column_indicator(x, idx(1).subs);
                t = x.data(:, b);
                
        end % switch
        
        if length(idx) > 1,
            t = subsref(t, idx(2:end));
        end
        
end

end % function subsref


%!shared x s t data
%! x = stk_dataframe(rand(3, 2));
%! s = {'a'; 'b'; 'c'};
%! t = {'xx' 'yy'};

%!test
%! x = stk_set_rownames(x, s);
%! assert (isequal (x.rownames, s))
%! assert (isequal (x.rownames{2}, 'b'))

%!test
%! x = stk_set_colnames(x, t);
%! assert (isequal (x.rownames, s))
%! assert (isequal (x.colnames, t))
%! assert (isequal (x.colnames{2}, 'yy'))

%!shared u data
%! u = rand(3, 2); data = stk_dataframe(u, {'x1', 'x2'});

%!assert (isequal (data.x2, u(:, 2)))
%!assert (data.x2(3) == u(3, 2))
%!error t = data.toto;
%!error t = data(1, 1).a;
%!error t = data(1, 1, 1);    % too many indices
%!error t = data{1};          % curly braces not allowed

%--- tests with a univariate dataframe ----------------------------------------

%!shared u data
%! u = rand(3, 1); data = stk_dataframe(u, 'x');

%!assert (isequal (data.x, u))
%!assert (isequal (double(data), u))
%!assert (isequal (data(2), u(2)))
%!assert (isequal (data(3, 1), u(3)))
%!error t = data(1, 1, 1);    % too many indices
