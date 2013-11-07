% STK_PLOT1DSIM is a plot helper for using with conditional sample paths
%
% CALL: stk_plot1dsim ( xi, zi, xt, zt, zp, zsim)
%
% STK_PLOT1DSIM plots the result of a 1D approximation, together with
% sample paths
%
% EXAMPLE: See examples/example05.m

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function stk_plot1dsim (xi, zi, xt, zt, zp, zsim)

% Create figure
figure1 = figure ('InvertHardcopy', 'off', 'Color', [1 1 1]);

% Create axes
axes1 = axes ('Parent', figure1, 'FontSize', 12);

dz = 1.96 * sqrt (abs (zp.var));
h = area (double (xt), [zp.mean - dz, 2*dz]);
set (h(1), 'FaceColor', 'none');
set (h(2), 'FaceColor', [0.8 0.8 0.8]);
set (h, 'LineStyle', '-', 'LineWidth', 1, 'EdgeColor', 'none');
hold on

plot (xt, zsim, '-',  'LineWidth', 1, 'Color', [0.39, 0.47, 0.64])
plot (xt, zt, '--', 'LineWidth', 3, 'Color', [0.39, 0.47, 0.64])
plot (xt, zp.mean, '-',  'LineWidth', 4, 'Color', [0.95 0.25 0.3])
plot (xi, zi, 'ko', 'LineWidth', 3, 'MarkerSize', 4, 'MarkerFaceColor', 'k')
hold off

set (axes1, 'Box', 'off')

end % stk_plot1dsim
