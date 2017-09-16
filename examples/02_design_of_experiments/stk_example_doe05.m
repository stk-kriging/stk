% STK_EXAMPLE_DOE05  A simple illustration of 1D Bayesian optimization
%
% Our goal here is to minimize the one-dimensional function
%
%    x |--> x * sin (x)
%
% over the interval [0; 4 * pi], using noisy evaluations.
%
% Evaluations points are chosen sequentially using either AKG criterion
% (default) or the EQI criterion (set SAMPCRIT_NAME to 'EQI');

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
%    Copyright (C) 2016 EDF R&D
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Tom Assouline, Florent Autret & Stefano Duhamel (for EDF R&D)

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

stk_disp_examplewelcome;
stk_figure ('stk_example_eqi_test');


%% Problem definition
% Here we define a one-dimensional optimization problem.
% The goal is to find the minimum of f on the domain BOX.

% 1D test function
f = @(x)(x .* sin (x));            % Define a 1D test function
DIM = 1;                           % Dimension of the factor space
BOX = stk_hrect ([0; 12], {'x'});  % Factor space (hyper-rectangle object)

% Variance of the observation noise
NOISE_VARIANCE = 2 ^ 2;

% Space discretization
GRID_SIZE = 200;  % Number of points in the grid
xg = stk_sampling_regulargrid (GRID_SIZE, DIM, BOX);

% Give names explicit names to the points of the grid
xg.rownames = arrayfun ...
    (@(i)(sprintf ('xg(%03d)', i)), 1:GRID_SIZE, 'UniformOutput', false)';

% Values of the function on the grid
zg = stk_feval (f, xg);
zg.colnames = {'z'};


%% Parameters affecting the sequential design algorithm

N0 = 5;                 % Size of the initial (regularly spaced) design
BUDGET = 100;           % Total evaluation budget
REESTIM_PERIOD = 10;    % How often should we re-estimate the cov parameters ?
SAMPCRIT_NAME = 'AKG';  % Choose a particular sampling criterion

% Note: the two criteria proposed here compute an "expected improvement" of
% some kind.  As such, they return positive values, and must be maximized.

switch SAMPCRIT_NAME
    case 'EQI'
        QUANTILE_ORDER = 0.5;
        POINT_BATCH_SIZE = @(x, n) BUDGET - n;
        sampcrit = stk_sampcrit_eqi ([], QUANTILE_ORDER, POINT_BATCH_SIZE);
    case 'AKG'
        sampcrit = stk_sampcrit_akg ();
end


%% Initial design of experiments

% Construction of the initial design
x0 = stk_sampling_regulargrid (N0, DIM, BOX);

% Give names explicit names to the points in the initial design
x0.rownames = arrayfun ...
    (@(i)(sprintf ('init%03d', i)), 1:N0, 'UniformOutput', false)';

% Simulate noisy observations of the initial design
z0 = stk_feval (f, x0);  z0.colnames = {'z'};
z0 = z0 + sqrt (NOISE_VARIANCE) * randn (size (z0));


%% Specification of the model (Gaussian process prior)

model0 = stk_model ('stk_materncov52_iso');

% Assume that the variance of the observation noise is known
model0.lognoisevariance = log (NOISE_VARIANCE);

% Add a prior on covariance parameters (log (sigma^2), log (1/rho))
model0.prior.mean = log ([1.0; 1/4.0]);
model0.prior.invcov = diag (1 ./ [+inf log(2)^2]);


%% Sequential design of experiments
% Here, evaluations points are chosen sequentially using the sampling criterion,
% starting from the initial design defined above.

% Plot only once in a while
PLOT_PERIOD = 5;

% Start from the initial design
x = x0;
z = z0;

for iter = 1:(BUDGET - N0)
    
    if mod (iter, REESTIM_PERIOD) == 1
        % Create posterior model object from scratch
        % (covariance function parameters estimated by marginal MAP)
        model = stk_model_gpposterior (model0, x, z);
    else
        % Update posterior model object
        % (covariance function parameters not re-estimated)
        model = stk_model_update (model, x_new, z_new);
    end
    
    % Instanciate sampling criterion object with model
    sampcrit.model = model;
    
    % Compute the EQI criterion on the grid
    [crit_val, z_pred] = sampcrit (xg);
    
    if mod (iter, PLOT_PERIOD) == 1
        % Figure: upper panel
        stk_subplot (2, 1, 1);  hold off;  % CG#12
        stk_plot1d ([],[], xg, zg, z_pred);
        hold on;  plot (x, z, 'k.');
        % Figure: lower panel
        stk_subplot (2, 1, 2);  cla;
        plot (xg, crit_val);  xlim (BOX);  ylabel (SAMPCRIT_NAME);
    end
    
    if all (crit_val == 0),  break,  end
    
    % Pick the point where the EQI is maximum as our next evaluation point
    [crit_max, i_max] = max (crit_val);
    x_new = xg(i_max, :);
    
    % Simulate a new observation at the selected location
    z_new = zg(i_max, :) + sqrt (NOISE_VARIANCE) * randn;
    
    % Indicate new point on the lower panel
    if mod (iter, PLOT_PERIOD) == 1
        hold on;  plot (x_new, crit_max, 'ro', 'MarkerFaceColor', 'y');
    end
    
    % Add the new evaluation to the DoE
    x = vertcat (x, x_new);
    z = vertcat (z, z_new);
    
    drawnow; % pause
    
end

% Display the final DoE
data = stk_dataframe ([x z], {'x', 'z'});  disp (data);

% Total number of evaluations ?
fprintf ('\nNumber of evaluations: %d + %d = %d.\n\n', N0, BUDGET - N0, BUDGET);


%#ok<*AGROW>

%!test stk_example_doe05;  close all;
