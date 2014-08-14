% STK_FIGURE is a replacement for 'figure' for use in STK's examples

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function h = stk_figure (varargin)

if mod (length (varargin), 2) ~= 0
    figname = varargin{1};
    user_options = varargin(2:end);
else
    figname = '';
    user_options = varargin;
end

% Get global STK options
options = stk_options_get ('stk_figure', 'properties');

% Create figure
h = figure (options{:});

% Create axes
stk_axes;

% Apply user-provided options
if ~ isempty (user_options)
    set (h, user_options{:});
end

% Set figure name and title
if ~ isempty (figname)
    set (h, 'Name', figname);
end

end % function stk_figure
