% STK_MAKE_MATCOV_AUTO_PARFOR [STK internal function]

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
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

function K = stk_make_matcov_auto_parfor(kfun, x, ncores, min_block_size)

%=== choose the actual block size & number of blocks
B = 0; % number of blocks of x_i's
n = size(x.a, 1); n_min = ceil(sqrt(min_block_size));
while 1, B = B + 1;
    % stop if the blocks are becoming too small
    if n/B < n_min, B = max(1,B-1); break; end
    % stop if the number of blocks is a multiple of ncores
    if mod(B*(B+1)/2, ncores) == 0, break; end
end
block_size = ceil(n / B); % the last block can be slightly smaller than the others
nb_blocks = B * (B + 1) / 2;

%=== prepare blocks
ind = zeros(B, 2); % begin/end positions
ind(:,1) = 1 + ((1:B)'-1) * block_size;
ind(:,2) = min(n, ind(:,1) + block_size - 1);
blocks = struct('i', cell(1,nb_blocks), 'j', [], 'xi', [], 'xj', [], 'K', []);
i = 1; j = 0;
for b = 1:nb_blocks;
    j = j+1; if(j>i), i=i+1; j=1; end
    blocks(b).i = i; blocks(b).xi = struct('a', x.a(ind(i,1):ind(i,2),:));
    blocks(b).j = j; blocks(b).xj = struct('a', x.a(ind(j,1):ind(j,2),:));
end

%=== process blocks
parfor b = 1:nb_blocks,
    blocks(b).K = feval(kfun, blocks(b).xi, blocks(b).xj);
    % FIXME: avoid computing each term in the covariance matrix twice
    % on the diagonal blocks !
end

%=== piece the whole matrix out from the blocks
K = zeros(n);
for b = 1:nb_blocks,
    i = blocks(b).i; j = blocks(b).j;
    K(ind(i,1):ind(i,2), ind(j,1):ind(j,2)) = blocks(b).K;
    K(ind(j,1):ind(j,2), ind(i,1):ind(i,2)) = (blocks(b).K)';
end

end % function stk_make_matcov_auto_parfor
