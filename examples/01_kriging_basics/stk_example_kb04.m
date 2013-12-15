% STK_EXAMPLE_KB04  Estimating the variance of the noise
%
% This example constructs an ordinary kriging approximation in 1D, with
% covariance parameters and noise variance estimated from the data.
%
% A Matern covariance function is used for the Gaussian Process (GP) prior. The
% parameters of this covariance function are estimated using the Restricted
% Maximum Likelihood (ReML) method.
%
% The mean function of the GP prior is assumed to be constant and unknown.
%
% In this example, the variance of the observation noise is not assumed to be
% known, and is instead estimated from the data together the parameters of the
% covariance function. This is triggered by the used of the fifth (optional)
% argument in the call to stk_param_estim.

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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb04');


%% Define a 1d test function

f = @(x)(- (0.8 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
DIM = 1;            % dimension of the factor space
BOX = [-1.0; 1.0];  % factor space

NT = 400;  % nb of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f, xt);


%% Generate a random sampling plan
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a randomly generated (uniform) design.
%
% Change the value of NOISEVARIANCE to add a Gaussian evaluation noise on
% the observations.
%

NOISEVARIANCE = 0.05;

NI = 30;                                    % nb of evaluations
xi = stk_sampling_randunif (NI, DIM, BOX);  % evaluation points
zi = stk_feval (f, xi);                     % evaluation results

zi = zi + sqrt (NOISEVARIANCE) * randn (NI, 1);

obs = stk_makedata (xi, zi);


%% Specification of the model
%
% We choose a Matern covariance, the parameters of which will be estimated from
% the data.
%
% The values of the parameters that are provided here, including the noise
% variance, are only used as an initial point for the optimization algorithm
% used in stk_param_estim().
%

% The following line defines a model with a constant but unknown mean (ordinary
% kriging) and a Matern covariance function. (Some default parameters are also
% set, but they will be replaced below by estimated parameters.)
model = stk_model ('stk_materncov_iso');
model = stk_setobs (model, obs);

% Noise variance
model.noise.cov = stk_homnoisecov (100 * eps);
% (this is not the true value of the noise variance !)


%% Estimate the parameters of the covariance function
%
% Here, the parameters of the Matern covariance function are estimated by the
% REML (REstricted Maximum Likelihood) method using stk_param_estim().
%

% Initial guess for the parameters for the Matern covariance
% (see "help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
param0 = log ([SIGMA2; NU; 1/RHO1]);

% Initial guess for the (log of the) noise variance
lnv0 = 2 * log (std (zi) / 100);

[param, paramlnv] = stk_param_estim (model, param0, lnv0);

model.randomprocess.priorcov.cparam = param;
model.noise.cov.variance = exp (paramlnv);


%% Carry out kriging prediction

zp = stk_predict (model, xt);

% Visualisation
stk_plot1d (obs, stk_makedata (xt, zt), stk_makedata (xt, zp))
stk_title  ('Kriging prediction');
stk_labels ('input variable x', 'response z');

model %#ok<NOPTS>
