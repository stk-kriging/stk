% STK_FACTORIALDESIGN constructs a "full factorial design" array
%
% CALL: D = stk_factorialdesign (LEVELS)
%
%   creates a full factorial design with levels LEVELS{1} for the first
%   variable, LEVELS{2} for the second variable, etc.  The output is an object
%   of the stk_factorialdesign class, which derives from stk_dataframe.
%
% CALL: D = stk_factorialdesign (LEVELS, COLNAMES)
%
%    allows to specify column names for the dataframe D.
%
% CALL: D = stk_factorialdesign (LEVELS, COLNAMES, ROWNAMES)
%
%    allows to specify row names as well.
%
% See also: stk_dataframe, stk_hrect

% Copyright Notice
%
%    Copyright (C) 2015, 2017, 2019 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function x = stk_factorialdesign (levels, varargin)

if nargin == 0   % default constructor
    levels = {[]};
end

if ~ iscell (levels)
    
    stk_error ('Expecting a cell array as first argument',  'TypeMismatch');
    
else
    
    % Guess the number of factors from the length of the cell array
    dim = length (levels);
    
    % Extract raw factor data and column names (when they are available)
    raw_levels = cell (1, dim);
    raw_levels_anyempty = false;
    colnames = cell (1, dim);
    colnames_allempty = true;
    for i = 1:dim
        li = levels{i};
        
        if isa (li, 'stk_dataframe')
            assert (size (li, 2) == 1);
            cn = get (li, 'colnames');
            if isempty (cn)
                colnames{i} = '';
            else
                colnames(i) = cn;
            end
            raw_levels{i} = double (li);
        elseif isnumeric (li)
            colnames{i} = '';
            raw_levels{i} = double (li(:));
            levels{i} = raw_levels{i};
        else
            errmsg = 'Only numeric factors are currently supported.';
            stk_error (errmsg, 'TypeMismatch');
        end
        
        if isempty (raw_levels{i})
            raw_levels_anyempty = true;
        end
        
        if ~ isempty (colnames{i})
            colnames_allempty = false;
        end
    end
    
    if (dim == 0) || raw_levels_anyempty
        
        xdata = zeros (0, dim);
        
    elseif dim == 1
        
        xdata = raw_levels{1};
        
    else
        
        % coordinate arrays
        coord = cell (1, dim);
        [coord{:}] = ndgrid (raw_levels{:});
        
        % design matrix
        xdata = zeros (numel (coord{1}), dim);
        for j = 1:dim
            xdata(:, j) = coord{j}(:);
        end
        
    end
    
    % base dataframe
    df = stk_dataframe (xdata, varargin{:});
    df = set (df, 'info', 'Created by stk_factorialdesign');
    
    % column names ?
    if isempty (get (df, 'colnames')) && ~ colnames_allempty
        df = set (df, 'colnames', colnames);
    end
    
    % "factorial design" object
    x = struct ();  x.levels = levels;
    x = class (x, 'stk_factorialdesign', df);
    
    try %#ok<TRYNC>
        % Starting with Matlab R2014b, graphics handles are objects
        superiorto ('matlab.graphics.axis.Axes');
    end
    
end % if

end % function


%!test stk_test_class ('stk_factorialdesign')

%--- constructor --------------------------------------------------------------

%!test % constructor with two factors + column names
%! x = stk_factorialdesign ({[0 1], [1 2 3]}, {'a', 'b'});
%! assert (isequal(x.colnames, {'a', 'b'}));
%! assert (isequal(get (x, 'colnames'), {'a', 'b'}));

% tests some incorrect values for 'levels'
%!error stk_factorialdesign ('bouh');

% categorical variable not supported yet
%!error stk_factorialdesign ({{'a' 'b'}});

%--- disp & display -----------------------------------------------------------

%!shared x, fmt
%! fmt = stk_disp_getformat ();
%! x = stk_sampling_regulargrid (3^2, 2);

%!test format rat;    disp (x);
%!test format long;   disp (x);
%!test format short;  disp (x);  format (fmt);

%!test disp (stk_sampling_regulargrid (0^1, 1));
%!test disp (stk_sampling_regulargrid (0^2, 2));

%!test display (x);

%--- size, length, end --------------------------------------------------------

%!error length (stk_sampling_regulargrid (7^2, 2))  % not defined

%!shared x
%! x = stk_factorialdesign ({[0 1], [0 1]});
%!assert (isequal (x(2:end, :), x(2:4, :)))
%!assert (isequal (x(2, 1:end), x(2, :)))
%!assert (isequal (x(2:end, 2:end), x(2:4, 2)))
%!error x(1:end, 1:end, 1:end)

%--- cat, vertcat, horzcat ----------------------------------------------------

% Note: the output is a plain stk_dataframe

%!shared x, y
%! x = stk_sampling_regulargrid (3^2, 2);
%! y = x;

%!test %%%% vercat
%! z = vertcat (x, y);
%! assert (strcmp (class (z), 'stk_dataframe'));
%! assert (isequal (double (z), [double(x); double(y)]));

%!test %%%% same thing, using cat(1, ...)
%! z = cat (1, x, y);
%! assert (strcmp (class (z), 'stk_dataframe'));
%! assert (isequal (double (z), [double(x); double(y)]));

%!test %%%% horzcat
%! y.colnames = {'y1' 'y2'};  z = horzcat (x, y);
%! assert (strcmp (class (z), 'stk_dataframe'));
%! assert (isequal (double (z), [double(x) double(y)]));

%!test %%%% same thing, using cat (2, ...)
%! z = cat (2, x, y);
%! assert (strcmp (class (z), 'stk_dataframe'));
%! assert (isequal (double (z), [double(x) double(y)]));

%!error cat (3, x, y)

%--- apply & related functions ------------------------------------------------

%!shared x, t
%! x = stk_sampling_regulargrid (3^2, 2);
%! t = double (x);

%!assert (isequal (apply (x, 1, @sum), sum (t, 1)))
%!assert (isequal (apply (x, 2, @sum), sum (t, 2)))
%!error u = apply (x, 3, @sum);

%!assert (isequal (apply (x, 1, @min, []), min (t, [], 1)))
%!assert (isequal (apply (x, 2, @min, []), min (t, [], 2)))
%!error u = apply (x, 3, @min, []);

%!assert (isequal (min (x), min (t)))
%!assert (isequal (max (x), max (t)))
%!assert (isequal (std (x), std (t)))
%!assert (isequal (var (x), var (t)))
%!assert (isequal (sum (x), sum (t)))
%!assert (isequal (mean (x), mean (t)))
%!assert (isequal (mode (x), mode (t)))
%!assert (isequal (prod (x), prod (t)))
%!assert (isequal (median (x), median (t)))

%--- bsxfun & related functions -----------------------------------------------

%!shared x1, x2, x3, u1, u2, u3
%! x1 = stk_sampling_regulargrid ([4 3], 2);  u1 = double (x1);
%! x2 = stk_sampling_regulargrid ([3 4], 2);  u2 = double (x2);
%! x3 = x1 + 1;                               u3 = u1 + 1;

%!test
%! z = bsxfun (@plus, x1, u2);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), u1 + u2))

%!test
%! z = bsxfun (@plus, u1, x2);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), u1 + u2))

%!test
%! z = bsxfun (@plus, x1, x2);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), u1 + u2))

%!test  z = min (x1, x2);     assert (isequal (double (z), min (u1, u2)));
%!test  z = max (x1, x2);     assert (isequal (double (z), max (u1, u2)));
%!error z = min (x1, x2, 1);
%!error z = max (x1, x2, 1);

%!test  z = x1 + x2;           assert (isequal (double (z), u1 + u2));
%!test  z = x1 - x2;           assert (isequal (double (z), u1 - u2));
%!test  z = x1 .* x2;          assert (isequal (double (z), u1 .* u2));
%!test  z = x3 .\ x2;          assert (isequal (double (z), u3 .\ u2));
%!test  z = x2 ./ x3;          assert (isequal (double (z), u2 ./ u3));
%!test  z = x3 .^ x2;          assert (isequal (double (z), u3 .^ u2));
%!test  z = realpow (x3, x2);  assert (isequal (double (z), realpow (u3, u2)));

%!test  z = (x1 == x2);        assert (isequal (double (z), (u1 == u2)));
%!test  z = (x1 ~= x2);        assert (isequal (double (z), (u1 ~= u2)));
%!test  z = (x1 <= x2);        assert (isequal (double (z), (u1 <= u2)));
%!test  z = (x1 >= x2);        assert (isequal (double (z), (u1 >= u2)));
%!test  z = (x1 < x2);         assert (isequal (double (z), (u1 < u2)));
%!test  z = (x1 > x2);         assert (isequal (double (z), (u1 > u2)));

%!test  z = x1 & x2;           assert (isequal (double (z), u1 & u2));
%!test  z = x1 | x2;           assert (isequal (double (z), u1 | u2));
%!test  z = xor (x1, x2);      assert (isequal (double (z), xor (u1, u2)));

%--- transpose, ctranspose ----------------------------------------------------

% Transposing a dataframe that represents a factorial design results in a
% dataframe that does NOT represent a factorial design

%!shared x
%! x = stk_factorialdesign ({[0 1], [0 1 2]});
%!assert (strcmp (class (x'), 'stk_dataframe'))
%!assert (strcmp (class (x.'), 'stk_dataframe'))
