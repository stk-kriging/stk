% STK_PARALLEL_FEVAL [overload STK function]

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

function z = stk_parallel_feval(eng, f, x, vectorized, min_block_size)

% TODO: remplacer vectorized par max_block_size ?

if vectorized % STK-style vectorization supported
    
    z = feval(f, x);
    
else % STK-style vectorization not supported => loop over the rows of x
    
    n = size(x, 1);
    z = zeros(n, 1);
    
    parfor i = 1:n,
        z(i) = feval(f, x(i, :));
    end
    
end

end % function
