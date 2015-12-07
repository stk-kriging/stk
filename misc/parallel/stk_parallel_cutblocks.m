% STK_PARALLEL_CUTBLOCKS [STK internal]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function blocks = stk_parallel_cutblocks(x, ncores, min_block_size)

x = double(x);
n = size(x, 1);

%--- Choose the actual block size & number of blocks ----------------------------

nb_blocks = min(ncores, max(1, floor(n / min_block_size)));

block_size = ceil(n / nb_blocks);

%--- Cut blocks -----------------------------------------------------------------

ind1 = 1 + ((1:nb_blocks)' - 1) * block_size;
ind2 = min(n, ind1 + block_size - 1);

% note: the last blocks can be slightly smaller than the others

blocks = struct('i', cell(1, nb_blocks), 'j', [], 'xi', [], 'K', []);

for b = 1:nb_blocks,
    
    blocks(b).i  = ind1(b):ind2(b);
    blocks(b).xi = x(blocks(b).i, :);
    
end

end % function
