% Example 02 constructs a kriging approximation in 1D
% ===================================================
%    Construct a kriging approximation in 1D. In this example, the model is
%    estimated from data.

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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


%% WELCOME

disp('#================#');
disp('#   Example 02   #');
disp('#================#');
disp('This example demonstrates how to carry out a kriging prediction');
disp('from a  set  of  observations.  In this example, the parameters');
disp('of the model are estimated from data. See also example01.m');
disp('');


%% DEFINE A 1D TEST FUNCTION

f = @(x)( -(0.8*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space
box = [-1.0; 1.0];                              % factor space

NG = 400; % nb of points in the grid
xg = stk_sampling_regulargrid(NG, DIM, box);
zg = stk_feval(f, xg);
xzg = stk_makedata(xg, zg); % data structure containing information about evaluations


%% GENERATE A RANDOM SAMPLING PLAN
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a randomly generated (uniform) design.
%
% Change the value of NOISEVARIANCE to add a Gaussian evaluation noise on
% the observations.
%

NOISEVARIANCE = 0.15^2;

NI = 6;                                     % nb of evaluations that will be used
xi = stk_sampling_randunif(NI, DIM, box);   % evaluation points
zi = stk_feval(f, xi);                      % evaluation results

if NOISEVARIANCE > 0,
    zi.a = zi.a + sqrt(NOISEVARIANCE) * randn(NI,1);
    % (don't forget that the data is in the ".a" field!)
end

xzi = stk_makedata(xi, zi);


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

% Homoscedastic white noise
noise_variance = max(NOISEVARIANCE, 1e-10);
model.noise.cov = stk_homnoisecov(noise_variance);
% Even if we don't assume that the observations are noisy,
% it is usually wiser to add a small "regularization noise".

% Set observations for the model
model = stk_setobs(model, xzi);


%% ESTIMATION OF THE PARAMETERS OF THE COVARIANCE
%
% Here, the parameters of the Matern covariance function are estimated by the
% REML (REstricted Maximum Likelihood) method using stk_param_estim().
%

% Initial guess for the parameters for the Matern covariance
% (see "help stk_materncov_iso" for more information)
model.randomprocess.priorcov.sigma2 = 1.0;  % variance parameter
model.randomprocess.priorcov.nu     = 4.0;  % regularity parameter
model.randomprocess.priorcov.rho    = 0.4;  % scale (range) parameter

% This is ugly... but it will get better when we have a @model class !
model.randomprocess.priorcov.cparam = stk_param_estim(model);


%% CARRY OUT THE KRIGING PREDICTION AND DISPLAY THE RESULT

zp  = stk_predict(model, xg);
xzp = stk_makedata(xg, zp);

% Display the result
figure;
n_std = sqrt(NOISEVARIANCE);
fig_title = sprintf('%s %.3e', 'Kriging prediction with noise std', n_std);
stk_plot1d(xzi, xzg, xzp, fig_title);
