% VIEW_INIT_2D view function

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function view_init_2d (algo, xi, zi, xg)

CONTOUR_LINES = 40; % number of levels in contour plots
XGDOT_STYLE    = {'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 2};
XIDOT_STYLE    = {'o', 'MarkerFaceColor', 'none', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerEdgeColor', [0.6 0 0.6]};

xt0 = algo.disp_xvals;
zt0 = algo.disp_zvals;
% keyboard

zp_ = stk_predict_withrep (algo.model, xi, zi, xt0);

figure(1)
h1 = subplot(2,2,1);
contour(xt0, zt0, CONTOUR_LINES);
%originalSize = get(gca, 'Position'); colorbar; set(h1, 'Position', originalSize);
colorbar
hold on
plot (xg.data(:, 1), xg.data(:, 2), XGDOT_STYLE{:});
plot (xi(:, 1), xi(:, 2), XIDOT_STYLE{:});
hold off;
stk_labels('x_1', 'x_2');
stk_title('function to be maximized');

subplot(2,2,2)
contour(xt0, zp_.mean, CONTOUR_LINES);
colorbar;
hold on
plot (xi(:, 1), xi(:, 2), XIDOT_STYLE{:});
hold off;
stk_labels('x_1', 'x_2');
stk_title('prediction');
% h=gca;
% set(h,'FontSize', 20)

end % function
