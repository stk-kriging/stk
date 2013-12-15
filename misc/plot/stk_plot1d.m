% STK_PLOT1D is a convenient plot function in 1D
%
% CALL: stk_plot1d (obsi, obst, preds)
%
% STK_PLOT1D plots the result of a 1D approximation

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function stk_plot1d (obsi, obst, pred, zsim)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

plot_obsi = ~ isempty (obsi);
plot_obst = (nargin > 1) && (~ isempty (obst));
plot_pred = (nargin > 2) && (~ isempty (pred));

% shaded area representing pointwise confidence intervals
if plot_pred,
    stk_plot_shadedci (pred.x, pred.z);
    hold on;
end

% plot sample paths
if (nargin > 3) && (~ isempty (zsim))
    plot (pred.x, zsim, '-',  'LineWidth', 1, 'Color', [0.39, 0.47, 0.64])
    hold on;
end

% ground truth (if available)
if plot_obst
    plot (obst.x, obst.z, '--', 'LineWidth', 3, 'Color', [0.39, 0.47, 0.64]);
    hold on;
end

% kriging predictor (posterior mean)
if plot_pred
    plot (pred.x, pred.z.mean, 'LineWidth', 4, 'Color', [0.95 0.25 0.3]);
    hold on;
end

% evaluations
if plot_obsi
    plot (obsi.x, obsi.z, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
end

hold off;  set (gca, 'box', 'off');

end % function stk_plot1d
