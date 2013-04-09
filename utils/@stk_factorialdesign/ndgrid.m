% NDGRID [FIXME: missing doc...]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function varargout = ndgrid(x)

d = length(x.levels);

if nargout > d
    
    stk_error('Too many output arguments.', 'TooManyOutputArgs');
    
else
    
    if (d == 0) || any(cellfun(@isempty, x.levels))
        
        varargout = repmat({zeros(0, d)}, 1, nargout);
        
    elseif d == 1
        
        varargout = {x.levels{1}(:)};
        
    else
        
        varargout = cell(1, nargout);
        [varargout{:}] = ndgrid(x.levels{:});
        
    end
    
end

end % function ndgrid
