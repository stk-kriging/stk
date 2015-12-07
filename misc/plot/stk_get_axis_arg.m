% STK_GET_AXIS_ARG [STK internal]

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

function [h, argin, n_argin] = stk_get_axis_arg (varargin)

if isempty (varargin)
    h = [];
    argin = {};
else
    h = varargin{1};
    if (all (ishghandle (h))) && (all (strcmp (get (h, 'type'), 'axes')))
        argin = varargin(2:end);
    else
        h = gca;
        argin = varargin;
    end
end

n_argin = length (argin);

end % function
