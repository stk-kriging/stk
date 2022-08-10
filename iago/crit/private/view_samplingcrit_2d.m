% VIEW_SAMPLINGCRIT_2D view function

% Copyright Notice
%
%    Copyright (C) 2015, 2020 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function view_samplingcrit_2d (algo, xg, xi, xinew, samplingcrit, h_fig) % Hcond + minimizer pos

XGDOT_STYLE    = {'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 3};
XIDOT_STYLE    = {'o', 'MarkerFaceColor', 'none', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerEdgeColor', [0.0 1.0 1.0]};
NEWDOT_STYLE = {'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 12};

xt0 = algo.disp_xvals;
ni = stk_get_sample_size (xi);
% zt0 = algo.disp_zvals;

[XX, YY] = meshgrid(xt0.data(:, 1), xt0.data(:,2));

if algo.searchgrid_unique
    ZZ = griddata(xg.data(:,1), xg.data(:,2), samplingcrit(), XX, YY);
else
    ZZ = griddata(xg.data(ni+1:end,1), xg.data(ni+1:end,2), samplingcrit(ni+1:end), XX, YY);
end

subplot(2,2,4)
pcolor (XX, YY, ZZ); shading(gca,'interp'); colorbar
hold on
plot (xg(:, 1), xg(:, 2), XGDOT_STYLE{:});
plot (xi(:, 1), xi(:, 2), XIDOT_STYLE{:});
hold off
stk_labels('x_1', 'x_2');
stk_title('sampling criterion to be minimized');

for i = [1 2 4]
    subplot(2,2,i)
    hold on, plot(xinew(1), xinew(2), NEWDOT_STYLE{:}); hold off
end

end % function
