% COMMONSIZE ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function varargout = commonsize (varargin)

n = length (varargin);

if n == 0,
    
    varargout = {};
    
else % at least one input argument
    
    varargout = cell (1, n);
    
    d = cellfun (@ndims, varargin);
    s = ones (n, max (d));
    for i = 1:n,
        s(i, 1:d(i)) = size (varargin{i});
    end
    
    smax = max (s);
    
    for i = 1:n,
        nrep = smax ./ s(i, :);
        if any (floor (nrep) ~= nrep)
            error ('Input arguments cannot be brought to a common size.');
        else
            varargout{i} = repmat (varargin{i}, nrep);
        end
    end
end

end % function commonsize
