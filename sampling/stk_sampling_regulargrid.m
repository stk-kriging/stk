% STK_SAMPLING_REGULARGRID builds a regular grid.
%
% CALL: X = stk_sampling_regulargrid(N, DIM)
%
%   builds a regular grid in the DIM-dimensional hypercube [0; 1]^DIM. If N is
%   an integer, a grid of size N is built; in this case, acceptable sizes are
%   such that N^(1/DIM) is an integer. If N is a vector of length N, a grid of
%   size prod(N) is built, with N(j) points on coordinate j.
%   
% CALL: X = stk_sampling_regulargrid(N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.
%
% See also: linspace

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
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

function x = stk_sampling_regulargrid(n, dim, box)

stk_narginchk(2, 3);

if (nargin < 3) || isempty(box)
    xmin = zeros(1, dim);
    xmax = ones(1, dim);
else
    [s1,s2] = size(box);
    if ~( (s1==2) && (s2==dim) ),
        error('box should be a 2xd array');
    end
    xmin = box(1,:);
    xmax = box(2,:);
end

if length(n) == 1
    n_coord = round(n^(1/dim));
    if n_coord^dim ~= n,
        stk_error('n^(1/dim) should be an integer', 'InvalidArgument');
    end
    n = n_coord * ones(1, dim);
else
    if length(n) ~= dim
        stk_error( ...
            'n should either be a scalar or a vector of length d', ...
            'IncorrectSize');
    end
end

coord = cell(1, dim);

if any(n==0), % empty grid
    
    xdata = zeros(0,dim);
    
else % at least one input point
        
    xmin = reshape(xmin, 1, dim); % make sure we work we row vectors
    xmax = reshape(xmax, 1, dim);   assert(all( xmin < xmax ));
    
    if dim == 1, % univariate inputs
        
        xdata = linspace(xmin, xmax, n)';
        coord = {xdata};
        
    else % multivariate inputs
        
        vect = cell(1, dim);
        for j = 1:dim,
            vect{j} = linspace(xmin(j), xmax(j), n(j));
        end
        
        [coord{:}] = ndgrid(vect{:});
        
        xdata = zeros(prod(n), dim);
        for j = 1:dim,
            xdata(:,j) = coord{j}(:);
        end
        
    end % if d == 1
    
end

x = struct('a', xdata, 'coord', {coord});

end % function stk_sampling_regulargrid


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%%
% Check error for incorrect number of input arguments

%!shared n, dim, box
%! n = 9; dim = 2; box = [0, 0; 1, 1];

%!error stk_sampling_regulargrid();
%!error stk_sampling_regulargrid(n);
%!test  stk_sampling_regulargrid(n, dim);
%!test  stk_sampling_regulargrid(n, dim, box);
%!error stk_sampling_regulargrid(n, dim, box, pi);

%%
% Check output argument

%!test
%! for dim = 1:3,
%!   n = 3^dim;
%!   x = stk_sampling_regulargrid(n, dim);
%!   assert(isstruct(x) && isnumeric(x.a));
%!   assert(isequal(size(x.a), [n dim]));
%!   u = x.a(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%! end

%!test
%! nn = [3 4 5];
%! for dim = 1:3,
%!   x = stk_sampling_regulargrid(nn(1:dim), dim);
%!   assert(isstruct(x) && isnumeric(x.a));
%!   assert(isequal(size(x.a), [prod(nn(1:dim)) dim]));
%!   u = x.a(:);
%!   assert(~any(isnan(u) | isinf(u)));
%!   assert((min(u) >= 0) && (max(u) <= 1));
%! end
