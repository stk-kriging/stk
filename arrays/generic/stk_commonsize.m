% STK_COMMONSIZE ...
%
% TODO: describe differences with Octave's common_size function.

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

function varargout = stk_commonsize (varargin)

n = length (varargin);

if n == 0,
    
    varargout = {};
    
else
    
    if n == 1
        % varargin{1} is expected to be a cell array in this case
        C = varargin{1};
        n = length (C);
    else
        C = varargin;
    end
    
    d = cellfun (@ndims, C);
    s = ones (n, max (d));
    for i = 1:n,
        s(i, 1:d(i)) = size (C{i});
    end
    
    smax = max (s);
    
    % Take care of empty dimensions, if any
    b = (smax > 0);
    smax = smax (b);
    s = s(:, b);
    
    nrep = ones (size (smax));
    for i = 1:n,
        nrep(b) = smax ./ s(i, :);
        nrep_one = (nrep == 1);
        if ~ all ((s(i, :) == 1) | nrep_one)
            error ('Input arguments cannot be brought to a common size.');
        elseif ~ all (nrep_one)
            C{i} = repmat (C{i}, nrep);
        end
    end
    
    if nargout > 1,
        varargout = C(1:nargout);
    else
        varargout = {C};
    end
    
end

end % function
