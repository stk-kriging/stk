% STK_PLOT_SHADEDCI [STK internal]
%
% STK_PLOT_SHADEDCI represents pointwise confidence itervals using a shaded
% area.

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
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

% Avoid a dependency on the stat toolbox in Matlab:
% norminv (1 - 0.05/2)  = 1.9600
% norminv (1 - 0.01/2)  = 2.5758
% norminv (1 - 0.001/2) = 3.2905
delta0 = [3.2905 2.5758 1.9600];
gray_level = [0.95 0.88 0.80];

% Use fill or area ?
persistent use_fill
if isempty (use_fill)
    v = regexp (version (), '^[0-9]*\.', 'match');
    
    if exist ('OCTAVE_VERSION', 'builtin')
        % In Octave 3.x, prefer area.  There are several problems with fill
        use_fill = (str2double (v{1}) >= 4);
    else
        % Problem: fill does not support the h_axes argument in Matlab < R2016a
        use_fill = (str2double (v{1}) >= 9);  % 9.0 is R2016a
    end
end

for k = 1:3
    
    delta = delta0(k) * sqrt (abs (z.var));
    patch_color = gray_level(k) * [1 1 1];
    
    if use_fill
        xx = [x; flipud(x)];
        zz = [z.mean - delta; flipud(z.mean + delta)];
        h_plot = fill (h_axes, xx, zz, patch_color, 'EdgeColor', patch_color);
    else
        h_plot = area (h_axes, x, [z.mean - delta, 2 * delta]);
        % Remove the first area object (between 0 and z.mean - delta)
        delete (h_plot(1));  h_plot = h_plot(2);
        set (h_plot, 'FaceColor', patch_color, 'LineStyle', '-', ...
            'LineWidth', 1, 'EdgeColor', patch_color);
    end
    hold on;
    
    % The options in 'opts', if any, are applied to all patch objects
    if ~ isempty (opts)
        set (h_plot, opts{:});
    end
    
end

hold off;

% Raise current axis to the top layer, to prevent it
% from being hidden by the grayed area
set (gca, 'Layer', 'top');

end % function


function [h_axes, x, z, opts] = parse_args_ (varargin)

% Extract axis handle (if it is present)
[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin < 2
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

x = varargin{1};
z = varargin{2};
opts = varargin(3:end);

end % function
