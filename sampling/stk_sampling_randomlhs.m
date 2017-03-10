% STK_SAMPLING_RANDOMLHS generates a random LHS design
%
% CALL: X = stk_sampling_randomlhs (N, DIM)
%
%   generates a random Latin Hypercube Sample of size N in the DIM-dimensional
%   hypercube [0; 1]^DIM.
%
% CALL: X = stk_sampling_randomlhs (N, DIM, BOX)
%
%   generates a random Latin Hypercube Sample of size N in the DIM-dimensional
%   hyperrectangle specified by the argument BOX, which is a 2 x DIM matrix
%   where BOX(1, j) and BOX(2, j) are the lower- and upper-bound of the interval
%   on the j^th coordinate.
%
% See also: stk_sampling_maximinlhs, stk_sampling_randunif

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

function x = stk_sampling_randomlhs (n, dim, box)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Read argument dim
if (nargin < 2) || ((nargin < 3) && (isempty (dim)))
    dim = 1;  % Default dimension
elseif (nargin > 2) && (~ isempty (box))
    dim = size (box, 2);
end

% Read argument box
if (nargin < 3) || isempty (box)
    box = stk_hrect (dim);
end

niter = 1;

x = stk_sampling_maximinlhs (n, dim, box, niter);

end % function


%%
% Check error for incorrect number of input arguments

%!shared x, n, dim, box
%! n = 10; dim = 2; box = [0, 0; 1, 1];

%!error x = stk_sampling_randomlhs ();
%!test  x = stk_sampling_randomlhs (n);
%!test  x = stk_sampling_randomlhs (n, dim);
%!test  x = stk_sampling_randomlhs (n, dim, box);
%!error x = stk_sampling_randomlhs (n, dim, box, pi);

%%
% Check that the output is a dataframe
% (all stk_sampling_* functions should behave similarly in this respect)

%!assert (isa(x, 'stk_dataframe'));

%%
% Check that column names are properly set, if available in box

%!assert (isequal (x.colnames, {}));

%!test
%! cn = {'W', 'H'};  box = stk_hrect (box, cn);
%! x = stk_sampling_randomlhs (n, dim, box);
%! assert (isequal (x.colnames, cn));

%%
% Check output argument

%!test
%! for dim = 1:5,
%!   x = stk_sampling_randomlhs(n, dim);
%!   assert(isequal(size(x), [n dim]));
%!   u = double(x); u = u(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%!   assert(stk_is_lhs(x, n, dim));
%! end
