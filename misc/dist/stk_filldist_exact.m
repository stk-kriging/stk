% STK_FILLDIST_EXACT computes the (exact) fill distance of a set of points.
%
% CALL: FD = stk_filldist_exact(X, BOX)
%
%    computes the fill distance FD of the dataset X in the hyper-rectangle
%    BOX, using the computational-geometric algorithm of L. Pronzato and 
%    W. G. Muller [1]. Recall that
%
%       D = max_{Y in BOX} min_{1 <= i <= n} norm(X(i,:) - Y),         (1)
%
%    where norm(.) denotes the Euclidean norm in R^d. Optimal designs with
%    respect to the fill distance are sometimes called "minimax" designs
%    (see, e.g., [2]).
%
% CALL: FD = stk_filldist_exact(X)
%
%    assumes that the fill distance is to be computed with respect to the
%    hyperrectangle BOX = [0; 1]^d.
%
% CALL: [FD, YMAX] = stk_filldist_exact(...)
%
%    also returns the point YMAX where the maximal distance is attained,
%    i.e., the argmax in equation (1).
%
% REFERENCES:
%
%   [1] Luc Pronzato and Werner G. Müller, "Design of computer 
%       experiments: space filling and beyond", Statistics and Computing,
%       22(3):681-701, 2012.
%
%   [2] Mark E. Johnson, Leslie M. Moore and Donald Ylvisaker, "Minimax
%       and maximin distance designs", Journal of Statistical Planning
%       and Inference, 26(2):131-148, 1990.
%
% See also: stk_filldist, stk_filldist_discretized, stk_dist, stk_mindist

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC, Guillaume Carlier & Florian Pasanisi
%
%    Authors:  Julien Bect             <julien.bect@supelec.fr>
%              Florian Pasanisi        <florian.pasanisi@gmail.com>
%              and Guillaume Carlier
%
%    Maintainer: Julien Bect <julien.bect@supelec.fr>
%
%    Guillaume Carlier and Florian Pasanisi wrote a first implementation 
%    of the algorithm  following the paper of  Pronzato & Müller (2011), 
%    which was subsequently  streamlined and adapted  to the STK toolbox
%    by Julien Bect.

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

function [fd, ymax] = stk_filldist_exact(x, box) %---------------------------------------

stk_narginchk(1, 2);
if isstruct(x), x = x.a; end
d = size(x, 2);

if nargin == 1,
    box = repmat([0; 1], 1, d);
elseif isstruct(box),
    box = box.a;
end    

%--- Construct a triangulation that covers [0; 1]^d -------------------------------------

x  = add_symm(x, box);   % extend using symmetries with respect to the faces
x  = unique(x, 'rows');  % remove duplicates
dt = delaunayn(x);       % Delaunay trianulation
nt = length(dt(:,1));    % number of triangles

%--- Compute centers and radiuses -------------------------------------------------------

center = zeros(nt, d);  % prepare for computing the centers
radius = zeros(nt, 1);  % prepare for computing the radiuses

for i = 1:nt,
    Z = x(dt(i, :), :);
    W = sum(Z.^2, 2);
    C = repmat(Z(1, :), d, 1) - Z(2:end, :);
    B = (W(1) - W(2:end))/2;
    center(i, :) = transpose(C\B);
    radius(i, 1) = sqrt(sum(center(i,:).^2) + W(1) - 2 * Z(1, :) * center(i, :)');
end

%--- Find the simplices for which the center is inside [0; 1]^d -------------------------

inside = true(size(center, 1), 1);
for j = 1:d,
    inside = inside & (center(:, j) >= box(1, j)) ...
                    & (center(:, j) <= box(2, j)) ;
end

[fd, imax] = max(radius .* double(inside));

ymax = center(imax, :);

end % function stk_filldist_exact -------------------------------------------------------


%%%%%%%%%%%%%%%
%   add_sym   %
%%%%%%%%%%%%%%%

function y = add_symm(x, box) %----------------------------------------------------------

[n d] = size(x);
k = 2 * d + 1;
y = repmat(x, k, 1);

for j = 1:d
    y(n*j+1:(j+1)*n, j) = 2 * box(1, j) - x(1:n, j);
    y((k-j)*n+1:(k+1-j)*n, j) = 2 * box(2, j) - x(1:n, j);
end

end % function add_symm -----------------------------------------------------------------


%%
% Check that ".a" structures are accepted

%!test
%! d = 3; x = rand(7, d); box = repmat([0; 1], 1, d);
%! fd1 = stk_filldist_exact(x, box);
%! fd2 = stk_filldist_exact(struct('a', x), struct('a', box));
%! assert(stk_isequal_tolabs(fd1, fd2));

%%
% One point in the middle of [0; 1]^d

%!test
%! for dim = 1:6,
%!     x = 0.5 * ones(1, dim);
%!     fd = stk_filldist_exact(x); % [0; 1]^d is the default box
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%%
% One point in the middle of [1; 2]^d

%!test
%! for dim = [1 3 7],
%!     box = repmat([1; 2], 1, dim);
%!     x = 1 + 0.5 * ones(1, dim);
%!     fd = stk_filldist_exact(x, box);
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end
