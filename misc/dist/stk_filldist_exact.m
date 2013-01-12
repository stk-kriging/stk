% STK_FILLDIST_EXACT computes the (exact) fill distance of a set of points
%
% CALL: ... [FIXME: docomentation]
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

function [fd, ymax] = stk_filldist_exact(x, box)

stk_narginchk(1, 2);
if isstruct(x), x = x.a; end
d = size(x, 2);

if nargin == 1,
    box = repmat([0; 1], 1, d);
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
