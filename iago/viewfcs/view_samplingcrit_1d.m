% VIEW_SAMPLINGCRIT_1D view function

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

function view_samplingcrit_1d (algo, xg, xi, xinew, samplingcrit, h_fig)

LINE2 = {'-', 'LineWidth', 3, 'Color', [0.95 0.25 0.3]};    % red line

figure (h_fig);

if algo.show1dsamplepaths && algo.show1dmaximizerdens > 1,
    subplot(3,1,3);
else
    subplot(2,1,2);
end

hold off
%plot(xg.data(ni+1:end), samplingcrit(ni+1:end), '-', 'LineWidth', 3, 'Color', [0.39, 0.47, 0.64])
[xg, xgi] = sort (xg);
ymin = min (samplingcrit(xgi));  ymax = max (samplingcrit(xgi));
delta = (ymax - ymin);  ymin = ymin - 0.05 * delta;  ymax = ymax + 0.05 * delta;
plot (xg, samplingcrit(xgi), LINE2{:});  ylim ([ymin ymax]);
%axis([-1 1 -6 1])
stk_labels('x', 'J(x)');
%stk_title('Sampling criterion to be minimized');
h=gca;
set(h,'Box', 'off')
set(h,'FontSize', 16)
drawnow

% display position of next evaluation
if algo.pause >= 2, disp('pause'); pause; end

if algo.show1dsamplepaths && algo.show1dmaximizerdens > 1,
    nplots = 3;
else
    nplots = 2;
end

for i = 1:nplots
    figure(h_fig)
    h = subplot(nplots, 1, i); hold on;
    plot([xinew.data xinew.data], ylim(h), 'LineWidth', 2, 'Color', [0.6, 0.6, 0.6])
    hold off;
end

drawnow

end % function view_samplingcrit_1d
