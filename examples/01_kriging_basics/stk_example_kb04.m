% Example 08 constructs a kriging approximation in 1D from noisy
% observations (estimates the noise)
% ===================================================
%    Construct a kriging approximation in 1D. In this example, the model is
%    estimated from data.

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

stk_disp_examplewelcome();


%% DEFINE A 1D TEST FUNCTION (THE SAME AS IN EXAMPLE01.M)

f = @(x)( -(0.8*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space
BOX = [-1.0; 1.0];                              % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_regulargrid(NT, DIM, BOX);
zt = stk_feval(f, xt);


%% GENERATE A RANDOM SAMPLING PLAN
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a randomly generated (uniform) design.
%
% Change the value of NOISEVARIANCE to add a Gaussian evaluation noise on
% the observations.
%

NOISEVARIANCE = 0.05;

NI = 30;                                    % nb of evaluations that will be used
xi = stk_sampling_randunif(NI, DIM, BOX);   % evaluation points
zi = stk_feval(f, xi);                      % evaluation results

zi = zi + sqrt(NOISEVARIANCE) * randn(NI,1);

obs = stk_makedata(xi, zi);


%% SPECIFICATION OF THE MODEL
%
% We choose a Matern covariance, the parameters of which will be estimated from the data.
%
% The values of the parameters that are provided here, including the noise variance, are
% only used as an initial point for the optimization algorithm used in stk_param_estim().
%

% The following line defines a model with a constant but unknown mean (ordinary
% kriging) and a Matern covariance function. (Some default parameters are also
% set, but they will be replaced below by estimated parameters.)
model = stk_model('stk_materncov_iso');
model = stk_setobs(model, obs);
model.noise.cov = stk_homnoisecov();


%% ESTIMATE THE PARAMETERS OF THE COVARIANCE FUNCTION
%
% Here, the parameters of the Matern covariance function are estimated by the
% REML (REstricted Maximum Likelihood) method using stk_param_estim().
%

% Initial guess for the parameters for the Matern covariance
% (see "help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
param0 = log([SIGMA2; NU; 1/RHO1]);

% Initial guess for the (log of the) noise variance
lnv0 = 2 * log(std(zi) / 100);

[param, paramlnv] = stk_param_estim(model, param0, lnv0);

model.randomprocess.priorcov.cparam = param;
model.noise.cov.variance = exp(paramlnv);


%% CARRY OUT KRIGING PREDICTION & DISPLAY THE RESULT

zp = stk_predict(model, xt);

stk_plot1d(obs, stk_makedata(xt, zt), stk_makedata(xt, zp))
xlabel('x'); ylabel('z');

model %#ok<NOPTS>
