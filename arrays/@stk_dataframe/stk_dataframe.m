% STK_DATAFRAME constructs a dataframe

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

x = struct ('data', x_data, ...
    'colnames', {{}}, 'rownames', {{}}, 'info', '');

x = class (x, 'stk_dataframe');

if ~ isempty (colnames)
    x = set (x, 'colnames', colnames);
end

if ~ isempty (rownames)
    x = set (x, 'rownames', rownames);
end

end % function stk_dataframe


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
