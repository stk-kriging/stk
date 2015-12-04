% HORZCAT [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function x = horzcat (x, y, varargin)

if nargin < 2,
    y = [];
end

%--- Get raw data ---------------------------------------------------------

x_data = double (x);
y_data = double (y);

%--- Get column and row names of inputs -----------------------------------

if isa (x, 'stk_dataframe')
    x_colnames = get (x, 'colnames');
    x_rownames = get (x, 'rownames');
else
    x_colnames = {};
    x_rownames = {};
end

if isa (y, 'stk_dataframe')
    y_colnames = get (y, 'colnames');
    y_rownames = get (y, 'rownames');
else
    y_colnames = {};
    y_rownames = {};
end

%--- Create output row names ----------------------------------------------

if isempty (x_rownames)
    
    rownames = y_rownames;
    
elseif isempty (y_rownames)
    
    rownames = x_rownames;
    
else
    
    if (~ isequal (size (x_rownames), size (y_rownames))) ...
            || (any (~ strcmp (x_rownames, y_rownames)))
        warning ('STK:horzcat:IncompatibleRowNames', sprintf ( ...
            ['Incompatible row names !\nThe output of horzcat will ' ...
            'have no row names.']));  rownames = {};
    else
        rownames = x_rownames;
    end
    
end

%--- Create output column names -------------------------------------------

bx = isempty (x_colnames);
by = isempty (y_colnames);

if bx && by, % none of the argument has row names
    
    colnames = {};
    
else % at least of one the arguments has column names
    
    if bx,  x_colnames = repmat ({''}, 1, size (x_data, 2));  end
    if by,  y_colnames = repmat ({''}, 1, size (y_data, 2));  end
    
    colnames = [x_colnames y_colnames];
    
end

%--- Create output --------------------------------------------------------

if strcmp (class (x), 'stk_dataframe')  %#ok<STISA>
    % Optimize for speed (no need to call constructor)
    x.data = [x_data y_data];
    x.colnames = colnames;
    x.rownames = rownames;
else
    x = stk_dataframe ([x_data y_data], colnames, rownames);
end

if ~ isempty (varargin),
    x = horzcat (x, varargin{:});
end

end % function


% IMPORTANT NOTE: [x y ...] fails to give the same result as horzcat (x, y,
% ...) in some releases of Octave. As a consequence, all tests must be
% written using horzcat explicitely.

%!shared u, v
%! u = rand(3, 2);
%! v = rand(3, 2);

%%
% Horizontal concatenation of two dataframes

%!test
%! x = stk_dataframe(u, {'x1' 'x2'});
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = horzcat (x, y);
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));

%!test
%! x = stk_dataframe(u, {'x1' 'x2'}, {'a'; 'b'; 'c'});
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = horzcat (x, y);
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));
%! assert(all(strcmp(z.rownames, {'a'; 'b'; 'c'})));

%!test
%! x = stk_dataframe(u, {'x1' 'x2'});
%! y = stk_dataframe(v, {'y1' 'y2'}, {'a'; 'b'; 'c'});
%! z = horzcat (x, y);
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), [u v]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));
%! assert(all(strcmp(z.rownames, {'a'; 'b'; 'c'})));

%!test  % incompatible row names
%! x = stk_dataframe (u, {'x1' 'x2'}, {'a'; 'b'; 'c'});
%! y = stk_dataframe (v, {'y1' 'y2'}, {'a'; 'b'; 'd'});
%! z = horzcat (x, y);
%! assert (isequal (z.rownames, {}));

%%
% Horizontal concatenation [dataframe matrix] or [matrix dataframe]

%!test
%! x = stk_dataframe (u);
%! z = horzcat (x, v);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u v]));

%!test
%! y = stk_dataframe (v);
%! z = horzcat (u, y);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u v]));

%%
% Horizontal concatenation of more than two elements

%!test
%! x = stk_dataframe(u, {'x1' 'x2'});
%! y = stk_dataframe(v, {'y1' 'y2'});
%! z = horzcat (x, y, u, v);
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), [u v u v]));
