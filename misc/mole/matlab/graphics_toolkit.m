% GRAPHICS_TOOLKIT queries or sets the default toolkit assigned to new figures.
%
% CALL: NAME = graphics_toolkit ()
%
%   returns the current default graphics toolkit NAME, which is always 'matlab'
%   in Matlab (this function is provided for Octave compatibility).
%
% CALL: NAME = graphics_toolkit (HLIST)
%
%   returns the graphics toolkit in use in each figure of the list (HLIST is a
%   list of figure handles). Again, this is always 'matlab'.
%
% CALL: graphics_toolkit (NAME)
% CALL: graphics_toolkit (HLIST, NAME)
%
%   do nothing in Matlab.

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

function name = graphics_toolkit (varargin)

if nargout > 0,    
    switch nargin
        case 0
            name = 'matlab';
        case 1
            name = repmat ({'matlab'}, size (varargin{1}));
        otherwise
            error ('Incorrect number of input arguments');
    end
end

end % function graphics_toolkit
