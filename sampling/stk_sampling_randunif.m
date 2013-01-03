% STK_SAMPLING_RANDUNIF generates uniformly distributed points.
%
% CALL: X = stk_sampling_randunif(N, DIM)
%
%   generates N points, independent and uniformly distributed in the
%   DIM-dimensional hypercube [0; 1]^DIM.
%
% CALL: X = stk_sampling_randunif(N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function x = stk_sampling_randunif(n, dim, box)
stk_narginchk(2, 3);

% read argument n
if (length(n) ~=1 ) && (length(n) ~= dim)
    error('n should either be a scalar or a vector of length d');
end

% read argument box
if (nargin < 3) || isempty(box)
    box = repmat([0; 1], 1, dim);
else
    stk_assert_box(box);
end

if n == 0, % empty sample    
    xdata = zeros(0,dim);    
else % at least one input point          
    xdata = stk_rescale(rand(n, dim), [], box);
end

x = struct('a', xdata);

end % function stk_sampling_randunif


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%%
% Check error for incorrect number of input arguments

%!shared x, n, dim, box
%! n = 10; dim = 2; box = [0, 0; 2, 2];

%!error x = stk_sampling_randunif();
%!error x = stk_sampling_randunif(n);
%!test  x = stk_sampling_randunif(n, dim);
%!test  x = stk_sampling_randunif(n, dim, box);
%!error x = stk_sampling_randunif(n, dim, box, pi);

%% 
% Check that the output is a struct with a numeric '.a' field
% (all stk_sampling_* functions should behave similarly in this respect)

%!test assert(isstruct(x) && isnumeric(x.a));

%%
% Check output argument

%!test
%! for dim = 1:5,
%!   x = stk_sampling_randunif(n, dim);
%!   assert(isequal(size(x.a), [n dim]));
%!   u = x.a(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%! end
