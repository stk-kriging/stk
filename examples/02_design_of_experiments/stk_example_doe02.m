% STK_EXAMPLE_DOE02  "Sequential Maximin" design
%
% In this example, a two-dimensional space-filling design is progressively
% enriched with new points using a "sequential maximin" approach. More
% precisely, the k-th point X(k, :) is selected to maximize the distance to the
% set of all previously selected points X(1, :), X(2, :), ..., X(k-1, :).
%
% NOTES:
%
%  * The resulting design is NOT optimal with respect to the maximin criterion
%    (separation distance).
%
%  * This procedure is not truly a *sequential* design procedure, since the
%    choice of the k-th point X(k, :) does NOT depend on the response at the
%    previously selected locations X(i, :), i < k.
%
% REFERENCE
%
%  [1] Emmanuel Vazquez and Julien Bect, "Sequential search based on kriging:
%      convergence analysis of some algorithms", In: ISI - 58th World
%      Statistics Congress of the International Statistical Institute (ISI'11),
%      Dublin, Ireland, August 21-26, 2011.

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

stk_disp_examplewelcome;  stk_figure ('stk_example_doe02');


%% Preliminaries

DIM = 2;  BOX = repmat ([0; 1], 1, DIM);

% start from, e. g., a random/maximin LHS
N0 = 10;  x = stk_sampling_maximinlhs (N0, DIM, BOX);

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
    % compute the current fill distance
    % & the point where the maximum is attained
    [fd, next_x] = stk_filldist (x, BOX);
    % plot
    cla;  plot (x(:, 1), x(:, 2), STYLE_CURRENT{:});
    hold on;  plot (next_x(:, 1), next_x(:, 2), STYLE_NEXT{:});
    stk_title (sprintf ('n = %d,  fd = %.2e\n', size (x, 1), fd));
    drawnow;  pause (0.5);
    % enrich the DoE
    x = vertcat (x, next_x);
end


%!test stk_example_doe02;  close all;
