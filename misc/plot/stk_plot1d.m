% STK_PLOT1D is a convenient plot function in 1D
%
% CALL: stk_plot1d (xi, zi, xt, zt, zp)
%
% STK_PLOT1D plots the result of a 1D approximation

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
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

function stk_plot1d (xi, zi, xt, zt, zp, zsim)

% Shaded area representing pointwise confidence intervals
if (nargin > 4) && (~ isempty (zp))
    stk_plot_shadedci (xt, zp);  hold on;
end

% Plot sample paths
if (nargin > 5) && (~ isempty (zsim))
    plot (xt, zsim, '-',  'LineWidth', 1, 'Color', [0.39, 0.47, 0.64]);  hold on;
end

% Ground truth
if (nargin > 3) && (~ isempty (zt))
    plot (xt, zt, '--', 'LineWidth', 3, 'Color', [0.39, 0.47, 0.64]);  hold on;
end

% Kriging predictor (posterior mean)
if (nargin > 4) && (~ isempty (zp))
    plot (xt, zp.mean, 'LineWidth', 3, 'Color', [0.95 0.25 0.3]);  hold on;
end

% Evaluations
if ~ isempty (zi)
    plot (xi, zi, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
end

hold off;  set (gca, 'box', 'off');  legend off;

end % function stk_plot1d
