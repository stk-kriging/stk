%          STK : a Small (Matlab/Octave) Toolbox for Kriging
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

nrep = 10;

for irep = 1:nrep,

    dim  = 1 + floor(rand*5);
    xmin = randn(1,dim);
    xmax = xmin + 1 + rand(1,dim);
    box  = [xmin; xmax];
    
    n = 10 + floor(rand*50);
    
    x = stk_sampling_maximinlhs(n, dim, box );
    
    assert(isstruct(x));
    assert(isequal(fieldnames(x), {'a'}));    
    assert(isequal(size(x.a), [n,dim]));    
    
    for j = 1:dim,
        
        y = x.a(:,j);
        
        assert(xmin(j) <= min(y));
        assert(xmax(j) >= max(y));
        
        y = (y - xmin(j)) / (xmax(j) - xmin(j));
        y = ceil(y * n);
        assert(isequal(sort(y), (1:n)'));
        
    end
    
end
