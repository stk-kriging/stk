% STK_TITLE [STK internal]
%
% STK_TITLE is a replacement for 'title' for use in STK's examples.

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

function h = stk_title (varargin)

if ischar (varargin{1})
    args = varargin(1);  % title
    user_options = varargin(2:end);
else
    args = varargin(1:2);  % axes handle + title
    user_options = varargin(3:end);
end

% Get global STK options
stk_options = stk_options_get ('stk_title', 'properties');

% Display title with STK options
h = title (args{:}, stk_options{:});

% Apply user-provided options
if ~ isempty (user_options)
    set (h, user_options{:});
end

end % function
