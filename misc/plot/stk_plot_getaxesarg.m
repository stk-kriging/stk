% STK_PLOT_GETAXISARG [STK internal]

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function [h_axes, argin, n_argin] = stk_plot_getaxesarg (varargin)

if isempty (varargin)
    
    h_axes = [];
    argin = {};
    n_argin = 0;
    
else
    
    % Check if the first argument is a handle to existing axes
    arg1_is_a_handle = false;
    try  %#ok<TRYNC>
        arg1_is_a_handle = (isscalar (varargin{1})) ...
            && (strcmp (get (varargin{1}, 'type'), 'axes'));
    end
    
    % Separate axis handle from the rest of the arguments
    if arg1_is_a_handle
        h_axes = varargin{1};
        argin = varargin(2:end);
    else
        h_axes = gca ();
        argin = varargin;
    end
    
    n_argin = length (argin);
    
end

end % function
