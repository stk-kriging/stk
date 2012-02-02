% STK_MAKE_MATCOV_INTER_PARFOR [STK internal function]

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version: 1.0
%    Authors: Julien Bect <julien.bect@supelec.fr>
%             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:     http://sourceforge.net/projects/kriging/
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

function K = stk_make_matcov_inter_parfor( x, xco, model, ncores, min_block_size )

%=== choose the actual block size & number of blocks
B1 = 1; n1 = size(x.a,1);   dB1 = 0;
B2 = 1; n2 = size(xco.a,1); dB2 = 0;
while 1, bs1 = n1/B1; bs2 = n2/B2;
    % stop if the blocks are becoming too small
    if bs1*bs2 < min_block_size, B1=B1-dB1; B2=B2-dB2; break; end
    % stop if the number of blocks is a multiple of ncores
    if mod( B1*B2, ncores ) == 0, break; end
    % split the largest of both sides
    if bs1 > bs2, B1=B1+1; dB1=1; dB2=0;
    else B2=B2+1; dB1=0; dB2=1; end
end
bs1 = ceil(bs1); bs2 = ceil(bs2); nb_blocks = B1*B2;

%=== prepare blocks
ind1 = zeros(B1,2); % begin/end positions in the first dimension
ind1(:,1) = 1 + ((1:B1)'-1)*bs1;
ind1(:,2) = min( n1, ind1(:,1)+bs1-1 );
ind2 = zeros(B2,2); % begin/end positions in the second dimension
ind2(:,1) = 1 + ((1:B2)'-1)*bs2;
ind2(:,2) = min( n2, ind2(:,1)+bs2-1 );
blocks = struct( 'i',cell(1,nb_blocks), 'j',[], 'xi',[], 'xcoj',[], 'K',[] );
for i = 1:B1,
    for j = 1:B2,
        b = i + (j-1)*B1; % block number
        blocks(b).i = i; blocks(b).xi = struct( 'a', x.a(ind1(i,1):ind1(i,2),:) );
        blocks(b).j = j; blocks(b).xcoj = struct( 'a', xco.a(ind2(j,1):ind2(j,2),:) );
    end
end

%=== process blocks
name = model.covariance_type; param = model.param; % avoids a "parfor" warning
parfor b = 1:nb_blocks,
    blocks(b).K = feval( name, blocks(b).xi, blocks(b).xcoj, param );
end

%=== piece the whole matrix out from the blocks
K = zeros(n1,n2);
for i = 1:B1,
    for j = 1:B2,
        b = i + (j-1)*B1; % block number
        K( ind1(i,1):ind1(i,2), ind2(j,1):ind2(j,2) ) = blocks(b).K;
    end
end

end % function stk_make_matcov_inter_parfor
