% STK_EXAMPLE_KB03  Ordinary kriging in 2D
%
% An anisotropic Matern covariance function is used for the Gaussian Process
% (GP) prior. The parameters of this covariance function (variance, regularity
% and ranges) are estimated using the Restricted Maximum Likelihood (ReML)
% method.
%
% The mean function of the GP prior is assumed to be constant and unknown. This
% default choice can be overridden by means of the model.lm property.
%
% The function is sampled on a space-filling Latin Hypercube design, and the
% data is assumed to be noiseless.

% Copyright Notice
%
%    Copyright 2016 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb03');

CONTOUR_LINES = 40; % number of levels in contour plots
DOT_STYLE = {'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4};


%% CHOICE OF A TWO-DIMENSIONAL TEST FUNCTION

CASENUM = 1;

switch CASENUM
    
    case 1,  % the classical BRANIN-HOO test function
        f = @stk_testfun_braninhoo;
        DIM = 2;
        BOX = [[-5; 10], [0; 15]];
        NI = 20;
        
    case 2,  % another test function
        f_ = inline (['exp(1.8*(x1+x2)) + 3*x1 + 6*x2.^2' ...
            '+ 3*sin(4*pi*x1)'], 'x1', 'x2');
        f  = @(x)(f_(x(:, 1), x(:, 2)));
        DIM = 2;
        BOX = [[-1; 1], [-1; 1]];
        NI = 40;  % this second function is much harder to approximate
        
end

% Optional: create an hyper-rectangle object for the input space
BOX = stk_hrect (BOX, {'x_1', 'x_2'})


%% COMPUTE AND VISUALIZE THE FUNCTION ON A 80 x 80 REGULAR GRID

% Size of the regular grid
NT = 80 ^ DIM;

% The function stk_sampling_regulargrid() does the job of creating the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);

% Compute the corresponding responses
zt = stk_feval (f, xt);

% Since xt is a regular grid, we can do a contour plot
stk_subplot (2, 2, 1);  contour (xt, f, CONTOUR_LINES);
axis (BOX);  stk_title ('function to be approximated');


%% CHOOSE A KRIGING (GAUSSIAN PROCESS) MODEL

% We start with a generic (anisotropic) Matern covariance function.
model = stk_model ('stk_materncov_aniso', DIM);

% As a default choice, a constant (but unknown) mean is used,
% i.e.,  model.lm = stk_lm_constant.
% model.lm = stk_lm_affine;     %%% UNCOMMENT TO USE A LINEAR TREND
% model.lm = stk_lm_quadratic;  %%% UNCOMMENT TO USE A "FULL QUADRATIC" TREND


%% EVALUATE THE FUNCTION ON A "MAXIMIN LHS" DESIGN

xi = stk_sampling_maximinlhs (NI, DIM, BOX);
zi = stk_feval (f, xi);

% Add the design points to the first plot
hold on;  plot (xi(:, 1), xi(:, 2), DOT_STYLE{:});


%% ESTIMATE THE PARAMETERS OF THE COVARIANCE FUNCTION

% Compute an initial guess for the parameters of the Matern covariance (param0)
% and a reasonable log-variance for a small "regularization noise"
[param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);

% % Alternative: user-defined initial guess for the parameters of
% % the Matern covariance (see "help stk_materncov_aniso" for more information)
% SIGMA2 = var (zi);
% NU     = 2;
% RHO1   = (BOX(2,1) - BOX(1,1)) / 10;
% RHO2   = (BOX(2,2) - BOX(1,2)) / 10;
% param0 = log ([SIGMA2; NU; 1/RHO1; 1/RHO2]);
% model.lognoisevariance = 2 * log (1e-5);

model.param = stk_param_estim (model, xi, zi, param0);


%% CARRY OUT KRIGING PREDICITION AND VISUALIZE

% Here, we compute the kriging prediction on each point of the grid
zp = stk_predict (model, xi, zi, xt);

% Display the result using a contour plot, to be compared with the contour
% lines of the true function
stk_subplot (2, 2, 2);  contour (xt, zp.mean, CONTOUR_LINES);
tsc = sprintf ('approximation from %d points', NI);  hold on;
plot (xi(:, 1), xi(:, 2), DOT_STYLE{:});
hold off;  axis (BOX(:));  stk_title (tsc);


%% VISUALIZE THE ACTUAL PREDICTION ERROR AND THE KRIGING STANDARD DEVIATION

stk_subplot (2, 2, 3);  pcolor (xt, log (abs (zp.mean - zt)));
hold on;  plot (xi(:, 1), xi(:, 2), DOT_STYLE{:});
hold off;  axis (BOX(:));  stk_title ('true approx error (log)');

stk_subplot (2, 2, 4);  pcolor (xt, 0.5 * log (zp.var));
hold on;  plot (xi(:, 1), xi(:, 2), DOT_STYLE{:});
hold off;  axis (BOX(:));  stk_title ('kriging std (log)');


%#ok<*NOPTS>

%!test stk_example_kb03;  close all;
