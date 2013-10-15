% STK_EXAMPLE_KB01 constructs an ordinary kriging approximation in 1D.
%
% A Matern covariance function is used for the Gaussian Process (GP) prior. The
% parameters of this covariance function are assumed to be known (i.e., no
% parameter estimation is performed here).
%
% The word 'ordinary' indicates that the mean function of the GP prior is
% assumed to be constant and unknown.
%
% The example first performs kriging prediction based on noiseless data (the
% kriging predictor, which is the posterior mean of the GP model, interpolates
% the data in this case) and then based on noisy data.
%

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
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

stk_disp_examplewelcome

% Use verbose output for the display of dataframes
save_verbosity = stk_options_get ('stk_dataframe', 'disp_format');
stk_options_set ('stk_dataframe', 'disp_format', 'verbose');


%% Define a 1d test function

f   = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
DIM = 1;            % dimension of the factor space
BOX = [-1.0; 1.0];  % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f, xt);

figure (1);
set (gcf, 'Name', 'Plot of the function to be approximated');
plot (xt, zt); xlabel ('x'); ylabel ('z');


%% Generate a space-filling design
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a "space-filling design".
%
% A regular grid (i.e., a grid with constant spacing) is constructed using
% stk_sampling_regulargrid(), which is equivalent to linspace() in this 1D
% example.
%

NI = 6;                                        % number of evaluations
xi = stk_sampling_regulargrid (NI, DIM, BOX);  % evaluation points
zi = stk_feval (f, xi);                        % evaluation results


%% Specification of the model
%
% We choose a Matern covariance with "fixed parameters" (in other  words, the
% parameters of the covariance function are provided by the user rather than
% estimated from data).
%

% The following line defines a model with a constant but unknown mean (ordinary
% kriging) and a Matern covariance function. (Some default parameters are also
% set, but we override them below.)
model = stk_model ('stk_materncov_iso');

% NOTE: the suffix '_iso' indicates an ISOTROPIC covariance function, but the
% distinction isotropic / anisotropic is irrelevant here since DIM = 1.

% Parameters for the Matern covariance function
% ("help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
model.param = log ([SIGMA2; NU; 1/RHO1]);


%% Carry out the kriging prediction and display the result
%
% The result of a kriging predicition is provided by stk_predict() in an object
% zp of type stk_dataframe, with two columns: "zp.mean" (the kriging mean) and
% "zp.var" (the kriging variance).
%

% Carry out the kriging prediction at points xt
zp = stk_predict (model, xi, zi, xt);

% Display the result
stk_plot1d (xi, zi, xt, zt, zp);
t = 'Kriging prediction based on noiseless observations';
set (gcf, 'Name', t); title (t);
xlabel ('x'); ylabel ('z');


%% Repeat the experiment in a noisy setting

NOISEVARIANCE = (1e-1)^2;

% Now the observations are perturbed by an additive Gaussian noise
noise = sqrt (NOISEVARIANCE) * randn (size (zi));
zi_n = zi + noise;

% We also include the observation noise in the model
model_n = model;
model_n.lognoisevariance = log (NOISEVARIANCE);

% Carry out the kriging prediction at locations xt
zp_n = stk_predict (model_n, xi, zi_n, xt);

% Display the result
stk_plot1d (xi, zi_n, xt, zt, zp_n);
t = 'Kriging prediction based on noisy observations';
set (gcf, 'Name', t); title (t);
xlabel ('x'); ylabel ('z');


%% Cleanup

% Restore output verbosity
stk_options_set ('stk_dataframe', 'disp_format', save_verbosity);
