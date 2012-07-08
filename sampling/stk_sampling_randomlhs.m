% STK_SAMPLING_RANDOMLHS generates a random LHS design.
%
% CALL: X = stk_sampling_randomlhs(N, DIM)
%
%   generates a random Latin Hypercube Sample of size N in the DIM-dimensional
%   hypercube [0; 1]^DIM.
%
% CALL: X = stk_sampling_randomlhs(N, DIM, BOX)
%
%   generates a random Latin Hypercube Sample of size N in the DIM-dimensional
%   hyperrectangle specified by the argument BOX, which is a 2 x DIM matrix
%   where BOX(1, j) and BOX(2, j) are the lower- and upper-bound of the interval
%   on the j^th coordinate.
%
% See also: stk_sampling_maximinlhs, stk_sampling_randunif

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function x = stk_sampling_randomlhs(n, dim, box)

stk_narginchk(2, 3);

if nargin < 3,
    box = [zeros(1, dim); ones(1, dim)];
end

niter = 1;

x = stk_sampling_maximinlhs(n, dim, box, niter);

end % function stk_sampling_randomlhs


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%%
% Check error for incorrect number of input arguments

%!shared n, dim, box
%! n = 10; dim = 2; box = [0, 0; 1, 1];

%!error stk_sampling_randomlhs();
%!error stk_sampling_randomlhs(n);
%!test  stk_sampling_randomlhs(n, dim);
%!test  stk_sampling_randomlhs(n, dim, box);
%!error stk_sampling_randomlhs(n, dim, box, pi);

%%
% Check output argument

%!test
%! for dim = 1:5,
%!   x = stk_sampling_randomlhs(n, dim);
%!   assert(isstruct(x) && isnumeric(x.a));
%!   assert(isequal(size(x.a), [n dim]));
%!   u = x.a(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%!   assert(stk_is_lhs(x, n, dim));
%! end
