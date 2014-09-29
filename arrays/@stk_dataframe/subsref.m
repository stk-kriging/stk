% SUBSREF [overload base function]

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
            
            stk_error ('Illegal indexing.', 'IllegalIndexing');
            
        else % ok, only one level of indexing
            
            L = length (idx(1).subs);
            
            if L == 1,  % linear indexing
                
                t = subsref (x.data, idx);
                
            elseif L == 2,  % matrix-style indexing
                
                I = idx(1).subs{1};
                J = idx(1).subs{2};
                
                c = get (x, 'colnames');
                if ~ isempty (c),
                    c = c(1, J);
                end
                
                r = get (x, 'rownames');
                if ~ isempty (r),
                    r = r(I, 1);
                end
                
                t = stk_dataframe (x.data(I, J), c, r);
                
            else
                stk_error ('Illegal indexing.', 'IllegalIndexing');
            end
            
        end
        
    case '{}'
        
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        
        t = get(x, idx(1).subs);
        
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
%! x = set(x, 'rownames', s);
%! assert (isequal (x.rownames, s))
%! assert (isequal (x.rownames{2}, 'b'))

%!test
%! x = set(x, 'colnames', t);
%! assert (isequal (x.rownames, s))
%! assert (isequal (x.colnames, t))
%! assert (isequal (x.colnames{2}, 'yy'))

%--- tests with a bivariate dataframe + column names --------------------------

%!shared u data
%! u = rand(3, 2);
%! data = stk_dataframe(u, {'x1', 'x2'});

%!assert (isequal (data.x2, u(:, 2)))
%!assert (data.x2(3) == u(3, 2))
%!error t = data.toto;
%!error t = data(1, 1).zzz;   % illegal multilevel indexing
%!error t = data(1, 1, 1);    % too many indices
%!error t = data{1};          % curly braces not allowed

%!test % legacy feature: data.a returns the 'mean' column if it exists
%! data = set(data, 'colnames', {'mean', 'x2'});
%! assert(isequal(data.a, u(:, 1)));

%!test % legacy feature: data.a returns the whole dataframe otherwise
%! data = set(data, 'colnames', {'x1', 'x2'});
%! assert(isequal(data.a, u));

%!test % select rows and columns
%! x = stk_dataframe (reshape (1:15, 5, 3), {'u' 'v' 'w'});
%! assert (isequal (x([3 5], 2), stk_dataframe ([8; 10], {'v'})));

%--- tests with a univariate dataframe ----------------------------------------

%!shared u data
%! u = rand(3, 1); data = stk_dataframe(u, {'x'});

%!assert (isequal (data.x, u))
%!assert (isequal (double (data),       u))
%!assert (isequal (double (data(2)),    u(2)))
%!assert (isequal (double (data(3, 1)), u(3)))
%!error t = data(1, 1, 1);    % too many indices
