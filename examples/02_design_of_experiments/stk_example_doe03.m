% STK_EXAMPLE_DOE03 provides a simple illustration of 1D Bayesian optimization
%
% Our goal here is to optimize the one-dimensional function
%
%    x |--> x * sin (x)
%
% over the interval [0; 4 * pi].
%
% A Matern 5/2 prior with known parameters is used.
%
% Evaluations points are chosen sequentially using the Expected Improvement (EI)
% criterion, starting from an initial design of N0 = 3 points.

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

stk_disp_examplewelcome;  stk_figure ('stk_example_doe03');


%% Problem definition
%
% Here we define a one-dimensional optimization problem.
%
% The goal is to find the maximum of f on the domain BOX.
%

% 1D test function
f = @(x)(x .* sin (x));  % Define a 1D test function
DIM = 1;                 % Dimension of the factor space
BOX = [0; 4 * pi];       % Factor space

% Space discretization
NT = 400;  % Number of points in the grid
x_grid = stk_sampling_regulargrid (NT, DIM, BOX);
x_grid.colnames = {'x'};

% Give names explicit names to the points of the grid
x_grid.rownames = arrayfun ...
    (@(i)(sprintf ('grid%03d', i)), 1:NT, 'UniformOutput', false)';

% Values of the function on the grid
z_grid = stk_feval (f, x_grid);
z_grid.colnames = {'z'};


%% Initial design of experiments
%
% We start with an initial design of N0 points, regularly spaced on the domain.
%

% Size of the initial design
N0 = 3;

% Construction of the initial design
x_init = stk_sampling_regulargrid (N0, DIM, BOX);
x_init.colnames = {'x'};

% Give names explicit names to the points in the initial design
x_init.rownames = arrayfun ...
    (@(i)(sprintf ('init%03d', i)), 1:N0, 'UniformOutput', false)';

% Values of the function on the initial design
z_init = stk_feval (f, x_init);
z_init.colnames = {'z'};


%% Specification of the model (Gaussian process prior)
%
% We choose a Matern 5/2 covariance with "fixed parameters" (in other
% words, the variance and range parameters of the covariance function are
% provided by the user rather than estimated from data).
%

model = stk_model ('stk_materncov52_iso');
% NOTE: the suffix '_iso' indicates an ISOTROPIC covariance function, but the
% distinction isotropic / anisotropic is irrelevant here since DIM = 1.

% Parameters for the Matern covariance function
% ("help stk_materncov52_iso" for more information)
SIGMA2 = 4.0 ^ 2;  % variance parameter
RHO1 = 2.0;        % scale (range) parameter
model.param = log ([SIGMA2; 1/RHO1]);

% Play with the parameter of the model to understand their influence on the
% behaviour of the algorithm !


%% Sequential design of experiments
%
% Here, evaluations points are chosen sequentially using the Expected
% Improvement (EI) criterion, starting from the initial design defined above.
%
% The algorithm stops when either the maximum number of iterations is reached or
% the maximum of the EI criterion falls below some threshold.
%

% Start with the initial design defined above
data = horzcat (x_init, z_init);

% Number of points to be added adaptively
NB_ITER = 20;

% Current value of the maximum of the Expected Improvement
EI_max = +inf;

% Value of EI_max for the stopping criterion
EI_max_stop = (max (z_grid) - min (z_grid)) / 1e4;

% Iteration number
iter = 0;

% Plot options
DOE_STYLE  = {'ko', 'MarkerFaceColor', 'k'};
NEXT_STYLE = {'ro', 'MarkerFaceColor', 'y'};

while (iter < NB_ITER) && (EI_max > EI_max_stop),
    
    % Trick: add a small "regularization" noise to our model
    model.lognoisevariance = 2 * log (min (1e-4, EI_max / 1e3));
    
    % Carry out the kriging prediction
    z_post = stk_predict (model, data.x, data.z, x_grid);
    
    % Compute the Expected Improvement (EI) criterion
    % (the fourth argument indicates that we want to MAXIMIZE f)
    EI = distrib_normal_ei (max (data.z), z_post.mean, sqrt (z_post.var), true);
    
    % Pick the point where the EI is maximum as our next evaluation point
    [EI_max, i_max] = max (EI);
    
    % Figure: upper panel
    subplot (2, 1, 1);  cla;
    plot (x_grid, z_grid);  xlim (BOX);  hold on;
    plot (x_grid, z_post.mean, 'r-');
    plot (data, DOE_STYLE{:});
    plot (x_grid(i_max), z_grid(i_max), NEXT_STYLE{:});
    
    % Figure: lower panel
    subplot (2, 1, 2);  cla;
    plot (x_grid, EI); xlim (BOX); hold on;
    plot (x_grid(i_max), EI_max, NEXT_STYLE{:});
    ylabel ('EI', 'FontWeight', 'bold');
    
    if EI_max > EI_max_stop,
        % Add the new evaluation to the DoE
        new_row = horzcat (x_grid(i_max, :), z_grid(i_max));
        data = vertcat (data, new_row); %#ok<AGROW>
        iter = iter + 1;
    end
    
    drawnow;  pause (0.2);
    
end

% Display the final DoE
disp (data);

% Total number of evaluations ?
fprintf ('\nNumber of evaluations: %d + %d = %d.\n\n', N0, iter, N0 + iter);
