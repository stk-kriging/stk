% STK_PLOT_SHADEDCI [STK internal]
%
% STK_PLOT_SHADEDCI represents pointwise confidence itervals using a shaded
% area.

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function h_plot = stk_plot_shadedci (varargin)

[h_axes, x, z, opts] = parse_args_ (varargin{:});

x = double (x);

delta = 1.96 * sqrt (abs (z.var));
h_plot = area (h_axes, x, [z.mean - delta, 2 * delta]);

% Remove the first area object (between 0 and z.mean - delta)
delete (h_plot(1));  h_plot = h_plot(2);

c = [0.8 0.8 0.8];  % Light gray
set (h_plot, 'FaceColor', c, 'LineStyle', '-', 'LineWidth', 1, 'EdgeColor', c);
if ~ isempty (opts)
    set (h_plot, opts{:});
end

% Raise current axis to the top layer, to prevent it
% from being hidden by the grayed area
set (gca, 'Layer', 'top');

end % function


function [h_axes, x, z, opts] = parse_args_ (varargin)

% Extract axis handle (if it is present)
[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin < 2,
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

x = varargin{1};
z = varargin{2};
opts = varargin(3:end);

end % function
