% STK_PLOT1D is a convenient plot function in 1D
%
% CALL: stk_plot1d ( xi, zi, xt, zt, zp )
%
% STK_PLOT1D plots the result of a 1D approximation
%
% EXAMPLE: See examples/example01.m

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function stk_plot1d(xi, zi, xt, zt, zp, h_axis)

if nargin < 6,
    % Create figure
    figure1 = figure('InvertHardcopy', 'off', 'Color', [1 1 1]);
    % Create axes
    h_axis = axes('Parent', figure1, 'FontSize', 12);
end

h = area(xt.a, [zp.a - 1.96 * sqrt(abs(zp.v)), 2 * 1.96 * sqrt(abs(zp.v))]);
set(h(1), 'FaceColor', 'none');
set(h(2), 'FaceColor', [0.8 0.8 0.8]);
set(h, 'LineStyle', '-', 'LineWidth', 1, 'EdgeColor', 'none');
hold on
plot(xt.a, zt.a, '--', 'LineWidth', 3, 'Color', [0.39, 0.47, 0.64]);
plot(xt.a, zp.a, 'LineWidth', 4, 'Color', [0.95 0.25 0.3]);
plot(xi.a, zi.a, 'ks', 'MarkerSize', 10, 'LineWidth', 3, ...
    'MarkerEdgeColor', [0.95 0.25 0.3], 'MarkerFaceColor', [0.8 0.8 0.8]);
hold off
set(h_axis, 'Box', 'off');
