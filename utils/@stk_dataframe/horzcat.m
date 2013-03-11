% HORZCAT concantenates one or several dataframes horizontally

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

function z = horzcat(x, y, varargin)

if isa(x, 'stk_dataframe') && isa(y, 'stk_dataframe')
    
    % In this case, [x y] will be an stk_dataframe also.
    
    data = [x.data y.data];
    colnames = [x.vnames y.vnames];
    if isempty(x.rownames),
        rownames = y.rownames;
    else
        if ~isempty(y.rownames) && ~all(strcmp(x.rownames, y.rownames))
            errmsg = 'Cannot concatenate because of incompatible row names.';
            stk_error(errmsg, 'IncompatibleRowNames');
        else            
            rownames = x.rownames;
        end
    end
    z = stk_dataframe(data, colnames, rownames);
    
else % In this case, z will be a matrix.
    
    z = [double(x) double(y)];

end

if ~isempty(varargin),
    z = horzcat(z, varargin{:});
end

end % function horzcat


%!shared u v
%! u = rand(3, 2);
%! v = rand(3, 2);

%%
% Horizontal concatenation of two dataframes

%!test
%! x = stk_dataframe(u, {'x1' 'x2'});
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = [x y];
%! assert(isa(z, 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));

%!test
%! x = stk_dataframe(u, {'x1' 'x2'}, {'a'; 'b'; 'c'});
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = [x y];
%! assert(isa(z, 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));
%! assert(all(strcmp(z.rownames, {'a'; 'b'; 'c'})));

%!test
%! x = stk_dataframe(u, {'x1' 'x2'});
%! y = stk_dataframe(v, {'y1' 'y2'}, {'a'; 'b'; 'c'});
%! z = [x y];
%! assert(isa(z, 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));
%! assert(all(strcmp(z.rownames, {'a'; 'b'; 'c'})));

%!error % incompatible row names
%! x = stk_dataframe(u, {'x1' 'x2'}, {'a'; 'b'; 'c'});
%! y = stk_dataframe(v, {'y1' 'y2'}, {'a'; 'b'; 'd'});
%! z = [x y];

%%
% Horizontal concatenation [dataframe matrix] or [matrix dataframe]

%!test
%! x = stk_dataframe(u);
%! z = [x v];
%! assert(isa(z, 'double') && isequal(z, [u v]));

%!test
%! y = stk_dataframe(v);
%! z = [u y];
%! assert(isa(z, 'double') && isequal(z, [u v]));

%%
% Horizontal concatenation of more than two elements

%!test
%! x = stk_dataframe(u, {'x1' 'x2'});
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = [x y u v];
%! assert(isa(z, 'double') && isequal(z, [u v u v]));
