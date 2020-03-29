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
%    Copyright (C) 2015-2017, 2020 CentraleSupelec
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

stk_disp_examplewelcome;  stk_figure ('stk_example_doe05');


%% Problem definition
% Here we define a one-dimensional optimization problem.
% The goal is to find the minimum of f on the domain BOX.

% 1D test function
f = @(x)(x .* sin (x));            % Define a 1D test function...
% f = @(x)((x - 6) .^ 2)           % ...or another one?
DIM = 1;                           % Dimension of the factor space
BOX = stk_hrect ([0; 12], {'x'});  % Factor space (hyper-rectangle object)

% Variance of the observation noise
NOISE_VARIANCE = 2 ^ 2;

% Space discretization
GRID_SIZE = 200;  % Number of points in the grid
xg = stk_sampling_regulargrid (GRID_SIZE, DIM, BOX);

% Give explicit names to the points of the grid
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

% Note: the three criteria proposed here compute an "expected improvement" of
% some kind.  As such, they return positive values, and must be maximized.

switch SAMPCRIT_NAME
    case 'EQI'
        QUANTILE_ORDER = 0.5;
        POINT_BATCH_SIZE = @(x, n) BUDGET - n;
        sampcrit = stk_sampcrit_eqi ([], QUANTILE_ORDER, POINT_BATCH_SIZE);
    case 'AKG'
        % Use the "approximate KG" criterion, with Scott's original method
        % for the construction of the reference grid (i.e., taking past
        % observations points plus the candidate point as the reference grid).
        sampcrit = stk_sampcrit_akg ();
    case 'KG'
        % Use the "exact KG" criterion, with can be obtained by taking the
        % reference grid equal to the entire input grid
        sampcrit = stk_sampcrit_akg ([], xg);
end


%% Initial design of experiments

% Construction of the initial design
x0 = stk_sampling_regulargrid (N0, DIM, BOX);

% Give explicit names to the points in the initial design
x0.rownames = arrayfun ...
    (@(i)(sprintf ('init%03d', i)), 1:N0, 'UniformOutput', false)';

% Simulate noisy observations of the initial design
z0 = stk_feval (f, x0);  z0.colnames = {'z'};
z0 = z0 + sqrt (NOISE_VARIANCE) * randn (size (z0));


%% Specification of the model (Gaussian process prior)

model0 = stk_model (@stk_materncov52_iso);
model0.lognoisevariance = nan;

% Remark: replace `nan` with `log (NOISE_VARIANCE)` in the previous line
% if you want to assume that the variance of the noise is known

% Add a prior on covariance parameters (log (sigma^2), log (1/rho))
model0.prior.mean = log ([1.0; 1/4.0]);
model0.prior.invcov = diag (1 ./ [+inf log(2)^2]);


%% Sequential design of experiments
% Here, evaluations points are chosen sequentially using the sampling criterion,
% starting from the initial design defined above.

% Plot only once in a while
PLOT_PERIOD = 5;

% Gather repetitions (makes it possible to let iter -> infinity)
REP_MODE = 'gather';  % Try 'ignore' instead if you want to slow things down...

% Initial data
x = x0;  z = z0;  data = stk_iodata (x0, z0, 'rep_mode', REP_MODE);

for iter = 1:(BUDGET - N0 + 1)
    
    if mod (iter, REESTIM_PERIOD) == 1
        % Construct a posterior model object from scratch
        % (covariance function parameters estimated by marginal MAP)
        model = stk_model_gpposterior (model0, data);
    else
        % Construct a new posterior model object
        % but keep previous ovariance function parameters (not re-estimated)
        model0_ = stk_get_prior_model (model);
        model = stk_model_gpposterior (model0_, data);
    end
    
    % Instanciate sampling criterion object with model
    sampcrit.model = model;
    
    % Compute the sampling criterion on the grid
    [crit_val, z_pred] = sampcrit (xg);
    
    if mod (iter, PLOT_PERIOD) == 1
               
        % Figure: upper panel
        stk_subplot (2, 1, 1);  cla;
        stk_plot1d ([],[], xg, zg, z_pred);
        hold on;  plot (x, z, 'ro', 'MarkerFaceColor', 'y', 'MarkerSize', 3);
        title (sprintf ('n = %d + %d = %d  //  noise std = %.3f', ...
            N0, iter - 1, N0 + iter - 1, ...
            exp (0.5 * model.prior_model.lognoisevariance)));
        
        % Figure: lower panel
        stk_subplot (2, 1, 2);  cla;
        plot (xg, crit_val);  xlim (BOX);  ylabel (SAMPCRIT_NAME);
        
    end
    
    % Stop if the criterion becomes equal to zero everywhere
    % or if the budget has been spent
    if all (crit_val == 0) || (N0 + iter > BUDGET),  break;  end
    
    % Pick the point where the sampling criterion is maximum
    % as our next evaluation point
    [crit_max, i_max] = max (crit_val);
    x_new = xg(i_max, :);
    
    % Simulate a new observation at the selected location
    z_new = zg(i_max, :) + sqrt (NOISE_VARIANCE) * randn;
    
    % Indicate new point on the lower panel
    if mod (iter, PLOT_PERIOD) == 1
        hold on;  plot (x_new, crit_max, 'ro', 'MarkerFaceColor', 'y');
    end
    
    % Add the new evaluation to the dataset
    x = [x; x_new];  z = [z; z_new];  data = stk_update (data, x_new, z_new);
    
    drawnow;  % pause
    
end

iter = iter - 1;

% Display the final dataset
tab = stk_iodata (x, z, 'rep_mode', 'gather');
disp (stk_dataframe ([data.input_data, data.output_data, data.output_nrep], ...
    {'x', 'z_mean', 'n_rep'}));

% Premature stopping ?
if N0 + iter < BUDGET
    warning ('The algorithm stopped prematurely.');
end

% Total number of evaluations ?
fprintf ('\nNumber of evaluations: %d + %d = %d.\n\n', N0, iter, N0 + iter);


%#ok<*AGROW>

%!test stk_example_doe05;  close all;
