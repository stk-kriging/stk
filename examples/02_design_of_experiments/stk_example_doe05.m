% STK_EXAMPLE_DOE05  A simple illustration of 1D Bayesian optimization
%
% Our goal here is to optimize the one-dimensional function
%
%    x |--> x * sin (x)
%
% over the interval [0; 4 * pi], using noisy evaluations. Evaluations points
% are chosen sequentially using the Expected Quantile Improvement (EQI)
% criterion.

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec & EDF R&D
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Tom Assouline, Florent Autret & Stefano Duhamel

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
%
% Here we define a one-dimensional optimization problem.
%
% The goal is to find the maximum of f on the domain BOX.
%

% 1D test function
f = @(x)(x .* sin (x));            % Define a 1D test function
DIM = 1;                           % Dimension of the factor space
BOX = stk_hrect ([0; 12], {'x'});  % Factor space (hyper-rectangle object)

% Space discretization
NT = 200;  % Number of points in the grid
xg = stk_sampling_regulargrid (NT, DIM, BOX);

% Give names explicit names to the points of the grid
xg.rownames = arrayfun ...
    (@(i)(sprintf ('xg(%03d)', i)), 1:NT, 'UniformOutput', false)';

% Values of the function on the grid
zg = stk_feval (f, xg);
zg.colnames = {'z'};

%% Initial design of experiments
%
% We start with an initial design of N0 points, regularly spaced on the domain.
%

% Size of the initial design
N0 = 4;

% Construction of the initial design
x0 = stk_sampling_regulargrid (N0, DIM, BOX);
x0= [x0;3.1];
%
% x0 = stk_sampling_randunif (N0, DIM, BOX);
% PLOT_OPTIONS = {'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k'};
% plot (x0(:, 1), x0(:, 2), PLOT_OPTIONS{:});
% stk_title (' Halton-RR2 sampling');

% Give names explicit names to the points in the initial design
x0.rownames = arrayfun ...
    (@(i)(sprintf ('init%03d', i)), 1:N0, 'UniformOutput', false)';

% Values of the function on the initial design
z0 = stk_feval (f, x0);
z0.colnames = {'z'};


%% Specification of the model (Gaussian process prior)
%
% We choose a Matern 5/2 covariance with "fixed parameters" (in other
% words, the variance and range parameters of the covariance function are
% provided by the user rather than estimated from data).
%

model = stk_model ('stk_materncov52_iso');
% NOTE: the suffix '_iso' indicates an ISOTROPIC covariance function, but the
% distinction isotropic / anisotropic is irrelevant here since DIM = 1.

% Definition of the variance of the noise
NOISEVARIANCE = 2^2;

% adding the noise variance to the model
model.lognoisevariance = log(NOISEVARIANCE);

% add a priori on covariance parameters
SIGMA2_mean = 1.0;  % variance parameter
RHO1_mean = 1.0;        % scale (range) parameter
model.prior.mean = log ([SIGMA2_mean; 1./RHO1_mean]);
model.prior.invcov = diag ([0 1./(log(2)^2)]);


%% ESTIMATE THE PARAMETERS OF THE COVARIANCE FUNCTION

% Now the observations are perturbed by an additive Gaussian noise
noise = sqrt (NOISEVARIANCE) * randn (size (z0));
z0_n = z0 + noise;   %% initial point with noise

% % Alternative: user-defined initial guess for the parameters of
% % the Matern covariance (see "help stk_materncov_aniso" for more information)
model.param = stk_param_estim (model, x0, z0_n);

% % Parameters for the Matern covariance function
% % ("help stk_materncov52_iso" for more information)
% SIGMA2 = 4.0 ^ 2;  % variance parameter
% RHO1 = 2.0;        % scale (range) parameter
% model_n.param = log ([SIGMA2; 1/RHO1]);


%% Sequential design of experiments
%
% Here, evaluations points are chosen sequentially using the Expected
% Quantile Improvement (EQI) criterion, starting from the initial design
% defined above.
%
% The algorithm stops when either the maximum number of iterations is reached or
% the maximum of the EQI criterion falls below some threshold.
%

% Number of points to be added adaptively
NB_ITER = 300;

% Current value of the maximum of the Expected Improvement
EQI_max = +inf;

% Value of EQI_max for the stopping criterion
EQI_max_stop = (max (zg) - min (zg)) / 1e5;

% Construct sampling criterion object
EQI_QUANTILE_ORDER = 0.5;
EQI_crit = stk_sampcrit_eqi (model, 'maximize', EQI_QUANTILE_ORDER);
EQI_crit = stk_model_update (EQI_crit, x0, z0_n);

% Iteration number
iter = 0;

%%

while (iter < NB_ITER) && (EQI_max > EQI_max_stop),
    
    % Compute the Expected Quantile Improvement (EQI) criterion on the grid
    [EQI_val, z_pred] = EQI_crit (xg);
    
    % Pick the point where the EQI is maximum as our next evaluation point
    [EQI_max, i_max] = max (EQI_val);
    
    % Figure: upper panel
    stk_subplot (2, 1, 1);  cla;
    stk_plot1d ([],[], xg, zg, z_pred);
    hold on;
    dataunique = unique(EQI_crit.model.input_data.x);
    for k = 1:length(dataunique)
        MINIMUM = 10^10;
        MAXIMUM = -10^10;
        for i = 1:length(EQI_crit.model.input_data.x)
            if EQI_crit.model.input_data.x(i) == dataunique(k)
                MINIMUM = min(MINIMUM, EQI_crit.model.output_data.z(i));
                MAXIMUM = max(MAXIMUM, EQI_crit.model.output_data.z(i));
            end
        end
        plot([dataunique(k) dataunique(k)],[MINIMUM MAXIMUM],'b-o','LineWidth',1)
        hold on;
    end
    
    % Figure: lower panel
    stk_subplot (2, 1, 2);  cla;
    plot (xg, EQI_val); xlim (BOX); hold on;
    plot (xg(i_max), EQI_max, 'ro', 'MarkerFaceColor', 'y');
    
    if EQI_max > EQI_max_stop,
        % Add the new evaluation to the DoE
        x_new = xg(i_max, :);
        z_new = zg(i_max, :) + sqrt (NOISEVARIANCE) * randn;
        EQI_crit = stk_model_update (EQI_crit, x_new, z_new);
        
        % Update model parameters
        EQI_crit.model.param = stk_param_estim (model, ...
            EQI_crit.model.input_data, EQI_crit.model.output_data);
        
        iter = iter + 1;
    end
    
    drawnow;  %pause (0.2);
    
end

% Display the final DoE
data = [EQI_crit.model.input_data EQI_crit.model.output_data];
data = stk_dataframe (data, {'x', 'z'});  disp (data);

% Total number of evaluations ?
fprintf ('\nNumber of evaluations: %d + %d = %d.\n\n', N0, iter, N0 + iter);


%!test stk_example_doe05;  close all;