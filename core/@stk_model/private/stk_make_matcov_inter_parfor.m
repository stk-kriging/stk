% STK_MAKE_MATCOV_INTER_PARFOR [STK internal function]

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%               Benoit Jan        <benoit.jan@supelec.fr>

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

function K = stk_make_matcov_inter_parfor(kfun, x0, x1, ncores, min_block_size)

x0 = double(x0);
x1 = double(x1);

%=== choose the actual block size & number of blocks
B0 = 1; n0 = size(x0, 1); dB0 = 0;
B1 = 1; n1 = size(x1, 1); dB1 = 0;
while 1, bs0 = n0/B0; bs1 = n1/B1;
    % stop if the blocks are becoming too small
    if bs0*bs1 < min_block_size, B0=B0-dB0; B1=B1-dB1; break; end
    % stop if the number of blocks is a multiple of ncores
    if mod(B0 * B1, ncores) == 0, break; end
    % split the largest of both sides
    if bs0 > bs1, B0 = B0 + 1; dB0 = 1; dB1 = 0;
    else B1 = B1 + 1; dB0 = 0; dB1 = 1; end
end
bs0 = ceil(bs0); bs1 = ceil(bs1); nb_blocks = B0*B1;

%=== prepare blocks
ind1 = zeros(B0,2); % begin/end positions in the first dimension
ind1(:,1) = 1 + ((1:B0)'-1)*bs0;
ind1(:,2) = min(n0, ind1(:,1) + bs0 - 1);
ind2 = zeros(B1,2); % begin/end positions in the second dimension
ind2(:,1) = 1 + ((1:B1)'-1)*bs1;
ind2(:,2) = min(n1, ind2(:,1) + bs1 - 1);
blocks = struct('i', cell(1,nb_blocks), 'j', [], 'xi', [], 'xcoj', [], 'K', []);
for i = 1:B0,
    for j = 1:B1,
        b = i + (j-1)*B0; % block number
        blocks(b).i = i; blocks(b).xi = x0(ind1(i,1):ind1(i,2), :);
        blocks(b).j = j; blocks(b).xcoj = x1(ind2(j,1):ind2(j,2), :);
    end
end

%=== process blocks
parfor b = 1:nb_blocks,
    blocks(b).K = feval(kfun, blocks(b).xi, blocks(b).xcoj);
end

%=== piece the whole matrix out from the blocks
K = zeros(n0,n1);
for i = 1:B0,
    for j = 1:B1,
        b = i + (j-1) * B0; % block number
        K(ind1(i,1):ind1(i,2), ind2(j,1):ind2(j,2)) = blocks(b).K;
    end
end

end % function stk_make_matcov_inter_parfor
