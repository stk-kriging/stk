% STK_SAMPLING_REGULARGRID builds a regular grid
%
% CALL: X = stk_sampling_regulargrid (N, DIM)
%
%   builds a regular grid in the DIM-dimensional hypercube [0; 1]^DIM. If N is
%   an integer, a grid of size N is built; in this case, acceptable sizes are
%   such that N^(1/DIM) is an integer. If N is a vector of length N, a grid of
%   size prod(N) is built, with N(j) points on coordinate j.
%
% CALL: X = stk_sampling_regulargrid (N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.
%
% See also: linspace

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function x = stk_sampling_regulargrid (n, dim, box)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Read argument dim
if (nargin < 2) || ((nargin < 3) && (isempty (dim)))
    dim = 1;  % Default dimension
elseif (nargin > 2) && (~ isempty (box))
    dim = size (box, 2);
end

% Read argument 'box'
if (nargin < 3) || isempty (box)
    xmin = zeros (1, dim);
    xmax = ones (1, dim);
    box_colnames = {};
else
    box = stk_hrect (box);  % convert input argument to a proper box
    box_data = double (box);
    box_colnames = get (box, 'colnames');
    xmin = box_data(1, :);
    xmax = box_data(2, :);
end

if length (n) == 1
    n_coord = round (n^(1/dim));
    if n_coord ^ dim ~= n,
        stk_error ('n^(1/dim) should be an integer', 'InvalidArgument');
    end
    n = n_coord * ones (1, dim);
else
    if length (n) ~= dim
        errmsg = 'n should either be a scalar or a vector of length d';
        stk_error (errmsg, 'IncorrectSize');
    end
end

% levels
levels = cell (1, dim);
for j = 1:dim,
    levels{j} = linspace (xmin(j), xmax(j), n(j));
end

x = stk_factorialdesign (levels, box_colnames);

end % function

%#ok<*TRYNC>


%%
% Check error for incorrect number of input arguments

%!shared x, n, dim, box
%! n = 9;  dim = 2;  box = [0, 0; 1, 1];

%!error x = stk_sampling_regulargrid ();
%!test  x = stk_sampling_regulargrid (n);
%!test  x = stk_sampling_regulargrid (n, dim);
%!test  x = stk_sampling_regulargrid (n, dim, box);
%!error x = stk_sampling_regulargrid (n, dim, box, pi);

%%
% Check that the output is an stk_dataframe
%   (all stk_sampling_* functions should behave similarly in this respect)
% and an stk_factorialdesign (special kind of stk_dataframe)

%!assert (isa (x, 'stk_dataframe'));
%!assert (isa (x, 'stk_factorialdesign'));

%%
% Check that column names are properly set, if available in box

%!assert (isequal (x.colnames, {}));

%!test
%! cn = {'W', 'H'};  box = stk_hrect (box, cn);
%! x = stk_sampling_regulargrid (n, dim, box);
%! assert (isequal (x.colnames, cn));

%%
% Check output argument

%!test
%! for dim = 1:3,
%!   n = 3^dim;
%!   x = stk_sampling_regulargrid(n, dim);
%!   assert(isequal(size(x), [n dim]));
%!   u = double(x); u = u(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%! end

%!test
%! nn = [3 4 5];
%! for dim = 1:3,
%!   x = stk_sampling_regulargrid(nn(1:dim), dim);
%!   assert(isequal(size(x), [prod(nn(1:dim)) dim]));
%!   u = double(x); u = u(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%! end
