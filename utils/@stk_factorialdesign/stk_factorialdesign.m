% STK_FACTORIALDESIGN constructs a factorial design

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

function x = stk_factorialdesign(levels, varargin)

if nargin == 0  % default constructor
    levels = {[]};
end

% number of factors
d = length(levels);

if ~iscell(levels) || (numel(levels) ~= d)
    
    errmsg = 'Expecting a "flat" cell array as first argument.';
    stk_error(errmsg, 'TypeMismatch');
    
else
    
    if ~all(cellfun(@isnumeric, levels))
        
        errmsg = 'Only numeric factors are currently supported.';
        stk_error(errmsg, 'TypeMismatch');
        
    else % ok, numeric levels, we know how to handle that
        
        if (d == 0) || any(cellfun(@isempty, levels))
            
            xdata = zeros(0, d);
            
        elseif d == 1
            
            xdata = levels{1}(:);
            
        else
            
            % coordinate arrays
            coord = cell(1, d);
            [coord{:}] = ndgrid(levels{:});
            
            % design matrix
            xdata = zeros(numel(coord{1}), d);
            for j = 1:d,
                xdata(:, j) = coord{j}(:);
            end
            
        end
        
        % base dataframe
        df = stk_dataframe(xdata, varargin{:});
        
        % "factorial design" object
        x = struct('levels', {levels});
        x = class(x, 'stk_factorialdesign', df);
        
    end % if
    
end % if

end % function stk_factorialdesign


%--- constructor --------------------------------------------------------------

%!test % default constructor
%! x = stk_factorialdesign();
%! assert(strcmp(class(x), 'stk_factorialdesign'));

%!test % constructor with two factors + column names
%! x = stk_factorialdesign({[0 1], [1 2 3]}, {'a', 'b'})
%! assert( isequal(x.colnames, {'a', 'b'}) );
%! assert( isequal(get(x, 'colnames'), {'a', 'b'}) );

% tests some incorrect values for 'levels'
%!error stk_factorialdesign('bouh');
%!error stk_factorialdesign(repmat({[0 1]}, 2, 2));

% categorical variable not supported yet
%!error stk_factorialdesign({{'a' 'b'}});

%--- disp & display -----------------------------------------------------------

%!shared x fmt
%! try % doesn't work on old Octave versions, nevermind
%!   fmt = get (0, 'Format');
%! catch
%!   fmt = nan;
%! end
%! x = stk_sampling_regulargrid (3^2, 2);

%!test format rat;      disp (x);
%!test format long;     disp (x);
%!test format short;    disp (x);
%!     if ~isnan (fmt), set (0, 'Format', fmt); end

%!test disp (stk_sampling_regulargrid (0^1, 1));
%!test disp (stk_sampling_regulargrid (0^2, 2));

%!test display (x);

%--- size, length, end --------------------------------------------------------

%!error length(stk_sampling_regulargrid(7^2, 2))  % not defined

%!shared x
%! x = stk_factorialdesign({[0 1], [0 1]});
%!assert (isequal (x(2:end, :), x(2:4, :)))
%!assert (isequal (x(2, 1:end), x(2, :)))
%!assert (isequal (x(2:end, 2:end), x(2:4, 2)))
%!error x(1:end, 1:end, 1:end)

%--- cat, vertcat, horzcat ----------------------------------------------------

% Note: the output is a plain stk_dataframe

%!shared x y
%! x = stk_sampling_regulargrid(3^2, 2);
%! y = x;

%!test %%%% vercat
%! z = vertcat(x, y);
%! assert (strcmp(class(z), 'stk_dataframe'));
%! assert (isequal(double(z), [double(x); double(y)]));

%!test %%%% same thing, using cat(1, ...)
%! z = cat(1, x, y);
%! assert (strcmp(class(z), 'stk_dataframe'));
%! assert (isequal(double(z), [double(x); double(y)]));

%!test %%%% horzcat
%! y.colnames = {'y1' 'y2'}; z = horzcat(x, y);
%! assert (strcmp(class(z), 'stk_dataframe'));
%! assert (isequal(double(z), [double(x) double(y)]));

%!test %%%% same thing, using cat(2, ...)
%! z = cat(2, x, y);
%! assert (strcmp(class(z), 'stk_dataframe'));
%! assert (isequal(double(z), [double(x) double(y)]));

%!error cat(3, x, y)

%--- apply & related functions ------------------------------------------------

%!shared x t
%! x = stk_sampling_regulargrid(3^2, 2);
%! t = double(x);

%!assert (isequal(apply(x, 1, @sum), sum(t, 1)))
%!assert (isequal(apply(x, 2, @sum), sum(t, 2)))
%!error u = apply(x, 3, @sum);

%!assert (isequal(apply(x, 1, @min, []), min(t, [], 1)))
%!assert (isequal(apply(x, 2, @min, []), min(t, [], 2)))
%!error u = apply(x, 3, @min, []);

%!assert (isequal(min(x), min(t)))
%!assert (isequal(max(x), max(t)))
%!assert (isequal(std(x), std(t)))
%!assert (isequal(var(x), var(t)))
%!assert (isequal(sum(x), sum(t)))
%!assert (isequal(mean(x), mean(t)))
%!assert (isequal(mode(x), mode(t)))
%!assert (isequal(prod(x), prod(t)))
%!assert (isequal(median(x), median(t)))

%--- bsxfun & related functions -----------------------------------------------

%!shared x1 x2 x3 u1 u2 u3
%! x1 = stk_sampling_regulargrid([4 3], 2);  u1 = double(x1);
%! x2 = stk_sampling_regulargrid([3 4], 2);  u2 = double(x2);
%! x3 = x1 + 1;                              u3 = u1 + 1;

%!test
%! z = bsxfun(@plus, x1, u2);
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), u1 + u2))

%!test
%! z = bsxfun(@plus, u1, x2);
%! assert(isa(z, 'double') && isequal(z, u1 + u2))

%!test
%! z = bsxfun(@plus, x1, x2);
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), u1 + u2))

%!test  z = min(x1, x2);     assert(isequal(double(z), min(u1, u2)));
%!test  z = max(x1, x2);     assert(isequal(double(z), max(u1, u2)));
%!error z = min(x1, x2, 1);
%!error z = max(x1, x2, 1);

%!test  z = x1 + x2;           assert(isequal(double(z), u1 + u2));
%!test  z = x1 - x2;           assert(isequal(double(z), u1 - u2));
%!test  z = x1 .* x2;          assert(isequal(double(z), u1 .* u2));
%!test  z = x3 .\ x2;          assert(isequal(double(z), u3 .\ u2));
%!test  z = x2 ./ x3;          assert(isequal(double(z), u2 ./ u3));
%!test  z = x3 .^ x2;          assert(isequal(double(z), u3 .^ u2));
%!test  z = realpow(x3, x2);   assert(isequal(double(z), realpow(u3, u2)));

%!test  z = (x1 == x2);        assert(isequal(double(z), (u1 == u2)));
%!test  z = (x1 ~= x2);        assert(isequal(double(z), (u1 ~= u2)));
%!test  z = (x1 <= x2);        assert(isequal(double(z), (u1 <= u2)));
%!test  z = (x1 >= x2);        assert(isequal(double(z), (u1 >= u2)));
%!test  z = (x1 < x2);         assert(isequal(double(z), (u1 < u2)));
%!test  z = (x1 > x2);         assert(isequal(double(z), (u1 > u2)));

%!test  z = x1 & x2;           assert(isequal(double(z), u1 & u2));
%!test  z = x1 | x2;           assert(isequal(double(z), u1 | u2));
%!test  z = xor(x1, x2);       assert(isequal(double(z), xor(u1, u2)));

%--- transpose, ctranspose ----------------------------------------------------

% Transposing a dataframe that represents a factorial design results in a
% dataframe that does NOT represent a factorial design

%!shared x
%! x = stk_factorialdesign({[0 1], [0 1 2]});
%!assert (strcmp (class(x'), 'stk_dataframe'))
%!assert (strcmp (class(x.'), 'stk_dataframe'))
