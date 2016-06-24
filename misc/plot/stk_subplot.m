% STK_SUBPLOT [STK internal]
%
% STK_SUBPLOT is a replacement for 'subplot' for use in STK's examples.

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function h_axes = stk_subplot (m, n, p, varargin)

% Get global STK options
stk_options = stk_options_get ('stk_axes', 'properties');

% Create axes
h_axes = subplot (m, n, p);

% Apply STK options first
if ~ isempty (stk_options)
  set (h_axes, stk_options{:});
end

% Apply user-provided options
if ~ isempty (varargin)
    set (h_axes, varargin{:});
end

end % function
