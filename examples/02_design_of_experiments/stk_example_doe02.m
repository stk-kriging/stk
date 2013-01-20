% Example: a very simple sequential space-filling design

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

stk_disp_examplewelcome();


%% Preliminaries

DIM = 2; BOX = repmat([0; 1], 1, DIM);

% start from, e. g., a random/maximin LHS
N0 = 10; x = stk_sampling_maximinlhs(N0, DIM, BOX); x = x.a;

% final size of the desired DoE
NB_ITER = 10;

% plot styles
STYLE_CURRENT = {'bo', 'MarkerFaceColor', 0.7 * ones(1, 3)};
STYLE_NEXT = {'ro', 'MarkerFaceColor', 'y'};


%% Sequential design
%
% This section can be run several times, to produce a bigger DoE !
%

for i = 1:NB_ITER,
    % compute the current fill distance & the point where the maximum is attained
    [fd, next_x] = stk_filldist(x, BOX);
    % plot
    figure(1); cla; plot(x(:, 1), x(:, 2), STYLE_CURRENT{:});
    hold on; plot(next_x(:, 1), next_x(:, 2), STYLE_NEXT{:});
    title(sprintf('n = %d,  fd = %.2e\n', size(x, 1), fd));
    drawnow; pause(0.5);
    % enrich the DoE
    x = [x; next_x];
end
