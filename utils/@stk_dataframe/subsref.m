% SUBSREF [FIXME: missing doc...]

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
        t = subsref(x.data, idx);
        
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
                b = strcmp(idx(1).subs, x.vnames);
                if ~any(b)
                    errmsg = sprintf('There is no variable named %s.', idx(1).subs);
                    stk_error(errmsg, 'UnknownVariable');
                else                    
                    t = x.data(:, b);
                end
                
        end % switch
end

if length(idx) > 1,
    t = subsref(t, idx(2:end));
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

%!test
%! u = rand(3, 2); data = stk_dataframe(u);
%! assert (isequal (data.x2, u(:, 2)))

%!test
%! u = rand(3, 2); data = stk_dataframe(u);
%! assert (data.x2(3) == u(3, 2))

%!error u = data.toto;

%!error x{1}
