% STK_PLOT1D is a convenient plot function in 1D
%
% CALL: stk_plot1d (obsi, obst, preds, title)
%
% STK_PLOT1D plots the result of a 1D approximation
%
% EXAMPLE: See examples/example01.m

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

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

function stk_plot1d(obsi, obst, pred, h_axis)
stk_narginchk(3, 4);

if nargin < 4,
    % Create figure
    figure1 = figure('InvertHardcopy', 'off', 'Color', [1 1 1]);
    % Create axes
    h_axis = axes('Parent', figure1, 'FontSize', 12);
end

axes(h_axis);

%=== checking arguments
plot_obsi = ~isempty(obsi);
plot_obst = ~isempty(obst);
plot_pred = ~isempty(pred);

% shaded area representing pointwise confidence intervals
if plot_pred,
    stk_plot_shadedci(pred.x, pred.z); hold on;
end

% ground truth (if available)
if plot_obst
    plot(obst.x.a, obst.z.a, '--', 'LineWidth', 3, 'Color', ...
         [0.39, 0.47, 0.64]);
    hold on
end

% kriging predictor (posterior mean)
if plot_pred
    plot(pred.x.a, pred.z.a, 'LineWidth', 4, 'Color', [0.95 0.25 0.3]);
end

% evaluations
if plot_obsi
    plot(obsi.x.a, obsi.z.a, 'ks', 'MarkerSize', 10, 'LineWidth', 3, ...
         'MarkerEdgeColor', [0.95 0.25 0.3], ...
         'MarkerFaceColor', [0.8  0.8 0.8]);
end

hold off;
set(gca, 'Box', 'off');
xlabel('x');
ylabel('z');
