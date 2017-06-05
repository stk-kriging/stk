% STK_SAMPLING_RANDUNIF generates uniformly distributed points
%
% CALL: X = stk_sampling_randunif (N, DIM)
%
%   generates N points, independent and uniformly distributed in the
%   DIM-dimensional hypercube [0; 1]^DIM.
%
% CALL: X = stk_sampling_randunif (N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.

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

function x = stk_sampling_randunif (n, dim, box)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Read argument n
if ~ ((isscalar (n)) && (isnumeric (n)))
    error ('n should be a numerical scalar.');
end

% Read argument dim
if (nargin < 2) || ((nargin < 3) && (isempty (dim)))
    dim = 1;  % Default dimension
elseif (nargin > 2) && (~ isempty (box))
    dim = size (box, 2);
end

% Read argument box
if (nargin < 3) || isempty (box)
    box = [];  % default box: [0; 1] ^ dim
else
    box = stk_hrect (box);  % convert input argument to a proper box
end

if isempty (box)
    if n == 0
        x = stk_dataframe (zeros (0, dim));  % Empty sample
    else
        x = stk_dataframe (rand (n, dim));
    end
else
    if n == 0
        x = stk_dataframe (box, [], {});   % Keep column names
        x = set_data (x, zeros (0, dim));  % Empty sample
    else
        % FIXME: stk_rescale should return a df when box is a df ?
        x = stk_dataframe (box, [], {});
        x = set_data (x, stk_rescale (rand (n, dim), [], box));
    end
end

end % function


%%
% Check error for incorrect number of input arguments

%!shared x, n, dim, box
%! n = 10; dim = 2; box = [0, 0; 2, 2];

%!error x = stk_sampling_randunif ();
%!test  x = stk_sampling_randunif (n);
%!test  x = stk_sampling_randunif (n, dim);
%!test  x = stk_sampling_randunif (n, dim, box);
%!error x = stk_sampling_randunif (n, dim, box, pi);

%%
% Check that the output is a dataframe
% (all stk_sampling_* functions should behave similarly in this respect)

%!assert (isa(x, 'stk_dataframe'));

%%
% Check that column names are properly set, if available in box

%!assert (isequal (x.colnames, {}));

%!test
%! cn = {'W', 'H'};  box = stk_hrect (box, cn);
%! x = stk_sampling_randunif (n, dim, box);
%! assert (isequal (x.colnames, cn));

%%
% Check output argument

%!test
%! for dim = 1:5,
%!   x = stk_sampling_randunif(n, dim);
%!   assert(isequal(size(x), [n dim]));
%!   u = double(x); u = u(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%! end
