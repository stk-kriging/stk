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
% See also: stk_factorialdesign, stk_hrect

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

if nargin > 3,
    
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
    
elseif nargin == 0  % Default constructor
    
    x_data = zeros (0, 1);
    colnames = {};
    rownames = {};
    
elseif strcmp (class (x), 'stk_dataframe')  %#ok<STISA>
    
    if nargin > 1,
        
        if iscell (colnames)
            x = set (x, 'colnames', colnames);
        elseif ~ isempty (colnames)
            stk_error (['colnames should be either a cell array ' ...
                'of strings or [].'], 'InvalidArgument');
            % Note: [] means "keep x.colnames"
            %       while {} means "no column names"
        end
        
        if nargin > 2
            if iscell (rownames)
                x = set (x, 'rownames', rownames);
            elseif ~ isempty (rownames)
                stk_error (['rownames should be either a cell array ' ...
                    'of strings or [].'], 'InvalidArgument');
                % Note: [] means "keep x.rownames"
                %       while {} means "no rownames names"
            end
        end
    end
    
    return  % We already have an stk_dataframe object
    
elseif isa (x, 'stk_dataframe')
    
    x_data = x.data;
    
    if nargin == 1,
        
        colnames = x.colnames;
        rownames = x.rownames;
        
    else % nargin > 1,
        
        if (isempty (colnames)) && (~ iscell (colnames))
            colnames = x.colnames;
        elseif ~ iscell (colnames)
            stk_error (['colnames should be either a cell array ' ...
                'of strings or [].'], 'InvalidArgument');
            % Note: [] means "keep x.colnames"
            %       while {} means "no column names"
        end
        
        if nargin == 2,
            
            rownames = x.rownames;
            
        else % nargin > 2,
            
            if (isempty (rownames)) && (~ iscell (rownames))
                rownames = x.rownames;
            elseif ~ iscell (rownames)
                stk_error (['rownames should be either a cell array ' ...
                    'of strings or [].'], 'InvalidArgument');
                % Note: [] means "keep x.rownames"
                %       while {} means "no rownames names"
            end
        end
    end
    
else  % Assume x is (or can be converted to) numeric data
    
    x_data = double (x);
    
    if nargin < 3,
        rownames = {};
        
        if nargin < 2,
            colnames = {};
        end
    end
end

[n, d] = size (x_data);

% Check colnames argument: must be a 1 x d cell array of strings
if ~ iscell (colnames)
    if isempty (colnames)
        colnames = {};
    else
        stk_error ('colnames should be a cell array.', 'TypeMismatch');
    end
elseif (~ isempty (colnames)) && (~ isequal (size (colnames), [1 d]))
    colnames = reshape (colnames, 1, d);
end

% Check rownames argument: must be a n x 1 cell array of strings
if ~ iscell (rownames)
    if isempty (rownames)
        rownames = {};
    else
        stk_error ('rownames should be a cell array.', 'TypeMismatch');
    end
elseif (~ isempty (rownames)) && (~ isequal (size (rownames), [n 1]))
    rownames = reshape (rownames, n, 1);
end

x = struct ('data', x_data, ...
    'colnames', {colnames}, 'rownames', {rownames}, 'info', '');

x = class (x, 'stk_dataframe');

try
    % Starting with Matlab R2014b, graphics handles are objects
    superiorto ('matlab.graphics.axis.Axes');
end

end % function


%!test stk_test_class ('stk_dataframe')

%!error x = stk_dataframe (1, {}, {}, pi);

%!test % default constructor
%! x = stk_dataframe ();
%! assert (isa (x, 'stk_dataframe') && isequal (size (x), [0 1]))

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
