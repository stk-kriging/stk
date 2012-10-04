% STK_PLOT1D is a convenient plot function in 1D
%
% CALL: stk_plot1d ( obsi, obst, preds, title )
%
% STK_PLOT1D plots the result of a 1D approximation
%
% EXAMPLE: See examples/example01.m

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
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
%
function stk_plot1d(obsi, obst, pred, ftitle)
stk_narginchk(3, 4);

set(gcf, 'InvertHardcopy', 'off', 'Color', [1 1 1]); % white background

%=== checking arguments
plot_obsi = ~isempty(obsi);
plot_obst = ~isempty(obst);
plot_pred = ~isempty(pred);

if plot_pred
    h = area(pred.x.a, [pred.z.a - 1.96 * sqrt(abs(pred.z.v)), 2 * 1.96 * sqrt(abs(pred.z.v))]);
    set(h(1), 'FaceColor', 'none');
    set(h(2), 'FaceColor', [0.8 0.8 0.8]);
    set(h, 'LineStyle', '-', 'LineWidth', 1, 'EdgeColor', 'none');
    hold on
end

if plot_obst
    plot(obst.x.a, obst.z.a, '--', 'LineWidth', 3, 'Color', ...
         [0.39, 0.47, 0.64]);
    hold on
end

if plot_pred
    plot(pred.x.a, pred.z.a, 'LineWidth', 4, 'Color', [0.95 0.25 0.3]);
end

if plot_obsi
    plot(obsi.x.a, obsi.z.a, 'ks', 'MarkerSize', 10, 'LineWidth', 3, ...
         'MarkerEdgeColor', [0.95 0.25 0.3], ...
         'MarkerFaceColor', [0.8  0.8 0.8]);
end
hold off
set(gca, 'Box', 'off');
xlabel('x'); ylabel('z');
if nargin > 3
    title(ftitle);
end
