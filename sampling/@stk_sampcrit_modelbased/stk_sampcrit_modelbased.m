% STK_SAMPCRIT_MODELBASED ...

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function crit = stk_sampcrit_modelbased (model, varargin)

if nargin == 1
    
    crit.model = model;
    
elseif nargin == 0
    
    % No input argument case: construct empty object
    crit.model = [];
    
else
    
    % Catch syntax errors (Octave only)
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
    
end % if

crit = class (crit, 'stk_sampcrit_modelbased', stk_sampcrit_base ());

end % function


%!test crit = stk_sampcrit_modelbased ();
