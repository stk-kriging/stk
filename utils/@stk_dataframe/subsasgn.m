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
        if length(idx) == 1
            if length(idx(1).subs) == 2                
                val = double(val);
                if ~isempty(val)
                    x.data = subsasgn(x.data, idx, val);
                else
                    if strcmp(idx(1).subs{1}, ':')
                        % remove columns
                        ii = idx(1).subs{2};
                        x.data(:, ii) = [];
                        x.vnames(ii) = [];
                    elseif strcmp(idx(1).subs{2}, ':')
                        % remove rows
                        ii = idx(1).subs{1};
                        x.data(ii, :) = [];
                        if ~isempty(x.rownames),
                            x.rownames(ii) = []; 
                        end
                    else
                        stk_error('Illegal indexing.', 'IllegalIndexing');
                    end
                end                
            else
                errmsg = 'stk_dataframe objects only support matrix-type indexing.';
                stk_error(errmsg, 'IllegalIndexing');
            end
        else
            stk_error('Illegal indexing.', 'IllegalIndexing');
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
                b = strcmp(idx(1).subs, x.vnames);
                if ~any(b)
                    errmsg = sprintf('There is no variable named %s.', idx(1).subs);
                    stk_error(errmsg, 'UnknownVariable');
                else
                    val = double(val);
                    if length(idx) > 1,
                        x.data(:, b) = subsasgn(x.data(:, b), idx(2:end), val);
                    else
                        x.data(:, b) = val;
                    end
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

%!test
%! x = stk_dataframe(rand(3, 2));
%! x(:, 2) = [];
%! assert (stk_isvalid (x))
%! assert (isequal(size(x), [3 1]))

%!test
%! x = stk_dataframe(rand(3, 2));
%! x(2, :) = [];
%! assert (stk_isvalid (x))
%! assert (isequal(size(x), [2 2]))

%!error x{1} = 2;
