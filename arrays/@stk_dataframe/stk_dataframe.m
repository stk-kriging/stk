% STK_DATAFRAME constructs a dataframe object
%
% CALL: D = stk_dataframe (X)
%
%    constructs a dataframe object from X. If X is a plain numeric array, then
%    D is dataframe without row or column names. If X already is an
%    stk_dataframe object, row names and column names are preserved when they
%    exist.
%
% CALL: D = stk_dataframe (X, COLNAMES)
%
%    allows to specify column names for the dataframe D. Row names from X are
%    preserved when they exist.
%
%    If COLNAMES is empty ([]), this is equivalent to D = stk_dataframe (X);
%    in particular, if X has column names, then D inherits from them.
%
%    If COLNAMES is an empty cell({}), the resulting dataframe has no column
%    names.
%
% CALL: D = stk_dataframe (X, COLNAMES, ROWNAMES)
%
%    allows to specify row names as well.
%
%    If ROWNAMES is empty ([]), this is equivalent to D = stk_dataframe (X,
%    COLNAMES); in particular, if X has row names, then D inherits from them.
%
%    If ROWNAMES is an empty cell({}), the resulting dataframe has no row names.
%
% NOTE: How to extract the underlying array
%
%    It is sometimes useful to extract from an stk_dataframe object the
%    underlying numerical (double precision) array.  This can be achieved either
%    using the 'data' field of the object:
%
%       x1 = x.data;        % x1 is a numerical array
%
%    or using a cast to double:
%
%       x2 = double (x);    % x2 is a numerical array too, identical to x1
%
%    Note that the second syntax remains valid even if x is a numerical array
%    (single, double, uint8...) instead of an stk_dataframe object.
%
% See also: stk_factorialdesign, stk_hrect

% Copyright Notice
%
%    Copyright (C) 2015, 2017, 2018 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function x = stk_dataframe (x, colnames, rownames)

if nargin == 0  % Default constructor
    
    x_data = zeros (0, 1);
    colnames = {};
    rownames = {};
    
elseif isa (x, 'stk_dataframe')
    
    if strcmp (class (x), 'stk_dataframe')  %#ok<STISA>
        
        if nargin > 1
            x = process_names_df (x, colnames, 'colnames', 2);   
            if nargin > 2
                x = process_names_df (x, rownames, 'rownames', 1);
            end
        end
        
        return  % We already have an stk_dataframe object
        
    else  % x belongs to a derived class
        
        x_data = x.data;
        
        if nargin == 1
            
            colnames = x.colnames;
            rownames = x.rownames;
            
        else % nargin > 1
            
            % colnames = [] means "keep x.colnames"
            if isempty (colnames) && ~ iscell (colnames)
                colnames = x.colnames;
            end
            
            % rownames missing or [] means "keep x.rownames"
            if (nargin == 2) || (isempty (rownames) && ~ iscell (rownames))
                rownames = x.rownames;
            end
        end
    end
    
else  % Assume x is (or can be converted to) numeric data
    
    x_data = double (x);
    
    if nargin < 3
        rownames = {};
        
        if nargin < 2
            colnames = {};
        end
    end
end

if isempty (x_data)
    
    [colnames, d] = process_names_empty (colnames, 'colnames', 2);
    [rownames, n] = process_names_empty (rownames, 'rownames', 1);    
    x_data = zeros (n, d);
    
else
    
    [n, d] = size (x_data);
    colnames = process_names_0 (colnames, 'colnames', [1 d]);
    rownames = process_names_0 (rownames, 'rownames', [n 1]);
        
end

x = struct ();

x.data     = x_data;
x.colnames = colnames;
x.rownames = rownames;
x.info     = '';

x = class (x, 'stk_dataframe');

try  %#ok<TRYNC>
    % Starting with Matlab R2014b, graphics handles are objects
    superiorto ('matlab.graphics.axis.Axes');
end

end % function


function arg = process_names_0 (arg, argname, s)

len = max (s);

if isempty (arg)
    arg = {};
else
    try
        if iscell (arg)
            arg = reshape (arg, s);
        else
            % Special case: try to interpret arg as a char vector
            assert (len == 1);
            arg = {char(arg)};
        end
    catch
        stk_error (errmsg_names (argname, len), 'InvalidArgument');
    end
end
    
end % function


function x = process_names_df (x, arg, argname, dim)

% Note: [] means "keep existing names", while {} means "no names"

if iscell (arg)    
    x = set (x, argname, arg);    
elseif ~ isempty (arg)
    try
        len = size (x, dim);
        assert (len == 1);
        % Special case: try to interpret arg as a char vector
        x = set (x, argname, {char(arg)});
    catch
        stk_error (errmsg_names (argname, len), 'InvalidArgument');
    end
end

end % function


function [arg, len] = process_names_empty (arg, argname, dim)

if isempty (arg)
    len = 0;
    arg = {};
elseif iscell (arg)
    len = numel (arg);
    if dim == 1
        arg = reshape (arg, len, 1);
    else
        arg = reshape (arg, 1, len);
    end
else
    try
        % Try to interpret colnames as a char vector
        len = 1;
        arg = {char(arg)};
    catch
        stk_error (errmsg_names (argname, len), 'InvalidArgument');
    end
end

end % function


function msg = errmsg_names (argname, len)

if len == 1
    msg = sprintf (['%s was expected to be a string (or char vector), a cell ' ...
        'array containing such a string (or char vector), or [].'], argname);
else
    msg = sprintf (['%s was expected to be a cell array containing %d strings ' ...
        '(or char vectors), or [].'], argname, len);
end

end


%!test stk_test_class ('stk_dataframe')

%!test % default constructor
%! x = stk_dataframe ();
%! assert (isa (x, 'stk_dataframe') && isequal (size (x), [0 0]))

%!test
%! y = stk_dataframe (rand (3, 2));
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [3 2]))

%!test
%! y = stk_dataframe (rand (3, 2), {'x', 'y'});
%! assert (isa (y, 'stk_dataframe') && isequal (size(y), [3 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))

%!test
%! y = stk_dataframe (rand (3, 2), {'x', 'y'}, {'a', 'b', 'c'});
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [3 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'}))

%!test
%! x = stk_dataframe (rand (3, 2));
%! y = stk_dataframe (x);
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [3 2]))

%!error
%! x = stk_dataframe (rand (3, 2));
%! y = stk_dataframe (x, pi);

%!error
%! x = stk_dataframe (rand (3, 2));
%! y = stk_dataframe (x, {}, pi);

%!test
%! x = stk_dataframe (rand (3, 2));
%! y = stk_dataframe (x, {'x' 'y'});
%! assert (isa (y, 'stk_dataframe') && isequal (size(y), [3 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))

%!test
%! x = stk_dataframe (rand (3, 2));
%! y = stk_dataframe (x, {'x' 'y'}, {'a', 'b', 'c'});
%! assert (isa (y, 'stk_dataframe') && isequal (size(y), [3 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'}))

%!test
%! x = stk_dataframe (rand (3, 2), {'x' 'y'});
%! y = stk_dataframe (x, [], {'a', 'b', 'c'});
%! assert (isa (y, 'stk_dataframe') && isequal (size(y), [3 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'}))

%!test
%! x = stk_dataframe (rand (3, 2), {'x' 'y'});
%! y = stk_dataframe (x, {}, {'a', 'b', 'c'});
%! assert (isa (y, 'stk_dataframe') && isequal (size(y), [3 2]))
%! assert (isequal (y.colnames, {}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'}))

%!test
%! x = stk_factorialdesign ({1:3, 1:2}, {'x' 'y'});
%! y = stk_dataframe (x, [], {'a' 'b' 'c' 'd' 'e' 'f'});
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [6 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'; 'd'; 'e'; 'f'}))

%!test
%! x = stk_factorialdesign ({1:3, 1:2}, {}, {'a' 'b' 'c' 'd' 'e' 'f'});
%! y = stk_dataframe (x, {'x' 'y'});
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [6 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'; 'd'; 'e'; 'f'}))

%!test
%! x = stk_factorialdesign ({1:3, 1:2}, {}, {'a' 'b' 'c' 'd' 'e' 'f'});
%! y = stk_dataframe (x, {'x' 'y'}, []);
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [6 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'; 'd'; 'e'; 'f'}))

%!test
%! x = stk_factorialdesign ({1:3, 1:2}, {'x' 'y'}, {'a' 'b' 'c' 'd' 'e' 'f'});
%! y = stk_dataframe (x);
%! assert (isa (y, 'stk_dataframe') && isequal (size (y), [6 2]))
%! assert (isequal (y.colnames, {'x' 'y'}))
%! assert (isequal (y.rownames, {'a'; 'b'; 'c'; 'd'; 'e'; 'f'}))

%!error
%! x = stk_factorialdesign ({1:3, 1:2});
%! y = stk_dataframe (x, pi);

%!error
%! x = stk_factorialdesign ({1:3, 1:2});
%! y = stk_dataframe (x, {}, pi);

%!test
%! x = stk_dataframe ([], {'a', 'b'});
%! assert (isequal (size (x), [0 2]))
%! assert (isequal (x.colnames, {'a' 'b'}));
%! assert (isequal (x.rownames, {}));

%!test
%! x = stk_dataframe ([], {'a', 'b'}, {'toto'});
%! assert (isequal (size (x), [1 2]))
%! assert (isequal (x.colnames, {'a' 'b'}));
%! assert (isequal (x.rownames, {'toto'}));

% Check that we tolerate char arguments for colnames/rownames

%!shared x

%!test
%! x = stk_dataframe (randn (10, 1), 'NOx');
%! assert (isequal (x.colnames, {'NOx'}));

%!test
%! y = stk_dataframe (x, 'toto');
%! assert (isequal (y.colnames, {'toto'}));

%!test
%! x = stk_dataframe (randn (1, 2), {}, 'aaa');
%! assert (isequal (x.rownames, {'aaa'}));

%!test
%! y = stk_dataframe (x, {}, 'tata');
%! assert (isequal (y.rownames, {'tata'}));
