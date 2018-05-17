% STK_LEGEND create a legend automatically
%
% CALL: stk_legend ()
%
%   creates a legend automatically, using only the graphical objcts for which a
%   non-empty DisplayName has been provided.
%
% CALL: h = stk_legend ()
%
%   also return a handle to the legend (which is either a numerical handle or a
%   Legend object, depending on the version of Matlab/Octave that you are
%   using).
%
% NOTE:
%
%   Creating and displaying a legend is painfully slow in some versions of M/O.
%   You should *really* avoid doing that inside a loop if you want a reasonably
%   fast update of the display.
%
% See also: stk_plot1d

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function h_legend = stk_legend ()

if nargin > 0
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

h_list = get (gca (), 'Children');
s_list = cell (size (h_list));

for i = 1:(length (h_list))
    s_list{i} = get (h_list(i), 'DisplayName');
end

b = ~ (strcmp (s_list, ''));
h_list = h_list(b);
s_list = s_list(b);

h_legend = legend (h_list, s_list);
set (h_legend, 'Color', 0.98 * [1 1 1]);

end % function
