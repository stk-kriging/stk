% STK_FACTORIALDESIGN [FIXME: missing doc...]

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

% number of factors
d = length(levels);

if ~iscell(levels) || (numel(levels) ~= d)
    errmsg = 'Expecting a "flat" cell array as first argument.';
    stk_error(errmsg, 'TypeMismatch');
end

% number of levels per factor
nlevels = zeros(1, d);

for j = 1:d,    
    if ~isnumeric(levels{j}),
        errmsg = 'Only numeric factors are currently supported.';
        stk_error(errmsg, 'TypeMismatch');
    end
    nlevels(j) = length(levels{j});
    if numel(levels{j}) ~= nlevels(j),
        errmsg = 'A VECTOR of levels is expected for each factor.';
        stk_error(errmsg, 'IncorrectSize');
    end
end

% number of points
n = prod(nlevels);

% coordinate arrays
if d == 1,
    coord = levels;
else
    coord = cell(1, d);
    [coord{:}] = ndgrid(levels{:});
end

% design matrix
xdata = zeros(n, d);
for j = 1:d,
    xdata(:, j) = coord{j}(:);
end

% base dataframe
df = stk_dataframe(xdata, varargin{:});

% "factorial design" object
x = struct('coord', {coord});
x = class(x, 'stk_factorialdesign', df);

end % function stk_factorialdesign


%--- disp & display -----------------------------------------------------------

%!shared x fmt
%! fmt = get(0, 'Format');
%! x = stk_sampling_regulargrid(3^2, 2);

%!test set(0, 'Format', 'short');     disp(x);
%!test set(0, 'Format', 'long');      disp(x);
%!test set(0, 'Format', 'rational');  disp(x);
%!test set(0, 'Format', fmt);

%!test disp(stk_sampling_regulargrid(0^1, 1));
%!test disp(stk_sampling_regulargrid(0^2, 2));

%!test display(x);

%--- cat, vertcat, horzcat ----------------------------------------------------

% Note: the output is a plain stk_dataframe

%!shared x y
%! x = stk_sampling_regulargrid(3^2, 2);
%! y = x;

%!test %%%% vercat
%! z = vertcat(x, y);
%! assert(strcmp(class(z), 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [double(x); double(y)]));

%!test %%%% same thing, using cat(1, ...)
%! z = cat(1, x, y);
%! assert(strcmp(class(z), 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [double(x); double(y)]));

%!test %%%% horzcat
%! y.colnames = {'y1' 'y2'}; z = horzcat(x, y);
%! assert(strcmp(class(z), 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [double(x) double(y)]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));

%!test %%%% same thing, using cat(2, ...)
%! z = cat(2, x, y);
%! assert(strcmp(class(z), 'stk_dataframe') && stk_isvalid(z));
%! assert(isequal(double(z), [double(x) double(y)]));
%! assert(all(strcmp(z.colnames, {'x1' 'x2' 'y1' 'y2'})));

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
