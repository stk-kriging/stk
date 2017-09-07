% VERTCAT [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function x = vertcat (x, y, varargin)

if nargin < 2
    y = [];
end

%--- Get raw data and concatenate -----------------------------------------

x_data = double (x);
y_data = double (y);

% We let the base vertcat function generate an error if needed
data = [x_data; y_data];

%--- Get column and row names  of inputs ----------------------------------

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

%--- Create output column names -------------------------------------------

if isempty (x_colnames)
    
    colnames = y_colnames;
    
elseif isempty (y_colnames)
    
    colnames = x_colnames;
    
else
    
    x_empty = cellfun (@isempty, x_colnames);
    y_empty = cellfun (@isempty, y_colnames);
    xy_equal = strcmp (x_colnames, y_colnames);
    
    if all (x_empty | y_empty | xy_equal)
        colnames = x_colnames;
        colnames(x_empty) = y_colnames(x_empty);
    else
        warning ('STK:vertcat:IncompatibleColNames', sprintf ( ...
            ['Incompatible column names !\nThe output of vertcat ' ...
            'will have no column names.']));  colnames = {};
    end
    
end

%--- Create output row names ----------------------------------------------

bx = isempty (x_rownames);
by = isempty (y_rownames);

if bx && by  % none of the argument has row names
    
    rownames = {};
    
else  % at least of one the arguments has row names
    
    if bx,  x_rownames = repmat ({''}, size (x_data, 1), 1);  end
    if by,  y_rownames = repmat ({''}, size (y_data, 1), 1);  end
    
    rownames = [x_rownames; y_rownames];
    
end

%--- Create output --------------------------------------------------------

if strcmp (class (x), 'stk_dataframe')  %#ok<STISA>
    % Optimize for speed (no need to call constructor)
    x.data = data;
    x.colnames = colnames;
    x.rownames = rownames;
else
    x = stk_dataframe (data, colnames, rownames);
end

if ~ isempty (varargin)
    x = vertcat (x, varargin{:});
end

end % function

%#ok<*SPWRN>


% IMPORTANT NOTE: [x; y; ...] fails to give the same result as vertcat (x, y,
% ...) in some releases of Octave. As a consequence, all tests must be written
% using vertcat explicitely.

%!shared u, v
%! u = rand (3, 2);
%! v = rand (3, 2);

%%
% Vertical concatenation of two dataframes

%!test
%! x = stk_dataframe (u);
%! y = stk_dataframe (v);
%! z = vertcat (x, y);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u; v]));

%!test  % the same, with row names this time
%! x = stk_dataframe (u, {}, {'a'; 'b'; 'c'});
%! y = stk_dataframe (v, {}, {'d'; 'e'; 'f'});
%! z = vertcat (x, y);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u; v]));
%! assert (all (strcmp (z.rownames, {'a'; 'b'; 'c'; 'd'; 'e'; 'f'})));

%!test  % the same, with row names only for the first argument
%! x = stk_dataframe (u, {}, {'a'; 'b'; 'c'});
%! y = stk_dataframe (v);
%! z = vertcat (x, y);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u; v]));

%!test  % incompatible variable names
%! u = rand (3, 1);  x = stk_dataframe (u, {'x'});
%! v = rand (3, 1);  y = stk_dataframe (v, {'y'});
%! z = vertcat (x, y);
%! assert (isequal (z.colnames, {}));

%%
% Vertical concatenation [dataframe; matrix]

%!test
%! x = stk_dataframe (u);
%! z = vertcat (x, v);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u; v]));

%!test  % the same, with row names for the first argument
%! x = stk_dataframe (u, {}, {'a'; 'b'; 'c'});
%! z = vertcat (x, v);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u; v]));

%%
% Vertical concatenation [matrix; dataframe]

%!test
%! y = stk_dataframe (v);
%! z = vertcat (u, y);
%! assert (isa (z, 'stk_dataframe') && (isequal (double (z), [u; v])));

%%
% Vertical concatenation of more than two elements

%!test
%! x = stk_dataframe (u);
%! y = stk_dataframe (v);
%! z = vertcat (x, y, u, v);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), [u; v; u; v]));

%%
% Vertical concatenation with missing column names

%!shared x, y
%! x = stk_dataframe (rand (2, 3), {'a', 'b', 'c'});
%! y = stk_dataframe (rand (3, 2), {'a', 'b'});
%! y = horzcat (y, rand(3, 1));  % last column name is missing

%!test
%! z = vertcat (x, y);
%! assert (isequal (z.colnames, {'a' 'b' 'c'}))

%!test
%! z = vertcat (y, x);
%! assert (isequal (z.colnames, {'a' 'b' 'c'}))
