% STK_ZLABEL is a replacement for 'zlabel' for use in STK's examples

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function h = stk_zlabel (varargin)

[h, varargin] = stk_get_axis_arg (varargin{:});
zlab = varargin{1};

% Get global STK options
stk_options = stk_options_get ('stk_zlabel', 'properties');
user_options = varargin(2:end);

% Apply to all axes
for i = 1:(length (h))
    
    % Set y-label and apply STK options
    zlabel (h(i), zlab, stk_options{:});
    
    % Apply user-provided options
    if ~ isempty (user_options)
        set (h(i), user_options{:});
    end
    
end

end % function stk_zlabel
