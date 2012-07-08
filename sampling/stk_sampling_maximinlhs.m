% STK_SAMPLING_MAXIMINLHS generates a "maximin" LHS design.
%
% CALL: X = stk_sampling_maximinlhs(N, DIM)
%
%   generates a "maximin" Latin Hypercube Sample of size N in the
%   DIM-dimensional hypercube [0; 1]^DIM. More precisely, NITER = 1000
%   independent random LHS are generated, and the one with the biggest
%   separation distance is returned.
%
% CALL: X = stk_sampling_maximinlhs(N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.
%
% CALL: X = stk_sampling_maximinlhs(N, DIM, BOX, NITER)
%
%   allows to change the number of independent random LHS that are used.
%
% See also: stk_mindist, stk_sampling_randomlhs

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
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

function x = stk_sampling_maximinlhs(n, d, box, niter)

stk_narginchk(2, 4);

if (nargin < 3) || isempty(box)
    xmin = zeros(1, d);
    xmax = ones(1, d);
else
    if ~isequal(size(box), [2, d]),
        error('box should be a 2xd array');
    end
    xmin = box(1,:);
    xmax = box(2,:);
end

if nargin < 4,
    niter = 1000;
end

if n == 0, % no input => no output
    
    xdata = zeros(0, d);
    
else % at least one input point
    
    xmin  = reshape(xmin, 1, d); % make sure we work we row vectors
    delta = reshape(xmax, 1, d) - xmin;   assert(all(delta > 0));
    
    xx = lhsdesign_(n, d, niter);
    
    xdata = ones(n, 1) * xmin + xx * diag(delta);
    
end

x = struct( 'a', xdata );

end


%%%%%%%%%%%%%%%%%%
%%% lhsdesign_ %%%
%%%%%%%%%%%%%%%%%%

function x = lhsdesign_( n, d, niter)

bestscore = 0;
x = [];

for j = 1:niter
    y = generatedesign_(n, d);    
    score = stk_mindist(y);    
    if isempty(x) || (score > bestscore)
        x = y;
        bestscore = score;
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%
%%% generatedesign_ %%%
%%%%%%%%%%%%%%%%%%%%%%%

function x = generatedesign_( n, d )

x = zeros(n, d);

for i = 1:d % for each dimension, draw a random permutation
    [sx, x(:,i)] = sort(rand(n,1)); %#ok<ASGLU>
end

x = (x - rand(size(x))) / n;

end


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%%
% Check error for incorrect number of input arguments

%!shared n, dim, box, niter
%! n = 20; dim = 2; box = [0, 0; 1, 1]; niter = 1;

%!error stk_sampling_maximinlhs();
%!error stk_sampling_maximinlhs(n);
%!test  stk_sampling_maximinlhs(n, dim);
%!test  stk_sampling_maximinlhs(n, dim, box);
%!test  stk_sampling_maximinlhs(n, dim, box, niter);
%!error stk_sampling_maximinlhs(n, dim, box, niter, pi);

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
