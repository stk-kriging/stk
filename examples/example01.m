% Example 01 constructs a kriging approximation in 1D
% ===================================================
%    Construct a kriging approximation in 1D. In this example, we choose a
%    Matern covariance with "fixed parameters" (in other words, the parameters
%    of the covariance function are provided by the user rather than 
%    estimated from data).
%


%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%

%% ******** WELCOME ********
disp('#================#');
disp('#   Example 01   #');
disp('#================#');
disp('This example demonstrates how to carry out a kriging prediction');
disp('from a set of possibly noisy observations.');

%% ******** DEFINE A 1D TEST FUNCTION ********

f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space
box = [-1.0; 1.0];                              % factor space

NG = 400; % nb of points in the grid
xg = stk_sampling_regulargrid( NG, DIM, box );
zg = stk_feval(f, xg);
xzg = stk_makedata(xg, zg); % data structure containing information about evaluations

figure(1); set( gcf, 'Name', 'Plot of the function to be approximated');
stk_plot1d( [], xzg, [] );

%% ******** GENERATE A SPACE-FILLING DESIGN ********
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a "space-filling design".
%
% A regular grid (i.e., a grid with constant spacing) is constructed using
% stk_sampling_regulargrid(), which is equivalent to linspace() in this
% 1d example.
%

NI = 6;                                         % nb of evaluations that will be used
xi = stk_sampling_regulargrid(NI, DIM, box);   % evaluation points
zi = stk_feval(f, xi);                        % structure of evaluation results
xzi = stk_makedata(xi, zi);

%% ******** SPECIFICATION OF THE MODEL ********
%

% The following line defines a model with a constant but unknown mean
% (ordinary kriging) and a Matern covariance function. (Some default
% parameters are also set, but we override them below.)
model = stk_model('stk_materncov_iso');

% NB: the suffix '_iso' indicates an ISOTROPIC covariance function, but the
% distinction isotropic / anisotropic is irrelevant here since DIM = 1.

% Parameters for the Matern covariance function ("help stk_materncov_iso" for more information)
model.randomprocess.priorcov.sigma2 = 1.0;  % variance parameter
model.randomprocess.priorcov.nu     = 4.0;  % regularity parameter
model.randomprocess.priorcov.rho    = 0.4;  % scale (range) parameter

% Set observations for the model. NB: We consider that observations are part
% of the model (the model is actualy a Gaussian process conditioned on a set of
% observations)
model = stk_setobs(model, xzi);

%% ******** CARRY OUT THE KRIGING PREDICTION AND DISPLAY THE RESULT ********
%
% The result of a kriging predicition is provided by stk_predict() in a
% structure, called "zp" in this example, which has two fields: "zp.a" (the
% kriging mean) and "zp.v" (the kriging variance).
%

% Carry out the kriging prediction at points xg.a
zp = stk_predict(model, xg);

% Display the result
figure(2)
xzp = stk_makedata(xg, zp);
stk_plot1d(xzi, xzg, xzp, 'Kriging prediction based on noiseless observations');

%% ******** REPEAT THE EXPERIMENT IN A NOISY SETTING ********
NOISEVARIANCE = (1e-1)^2;

% Make the observations perturbed by an additive Gaussian noise
noise = sqrt(NOISEVARIANCE) * randn(xzi.n, 1);
xzi_noisy = xzi;
xzi_noisy.z.a = xzi.z.a + noise; 

%=== There are two ways for specifying noisy observations in the model
% (1) information about the noise is included in the observation structure
%
%     model_noisy.noise.type = 'wwn';
%     xzi_noisy.x.v = NOISEVARIANCE * ones(xzi_noisy.n,1);
%
% (2) information about the noise is carried by the noise struture
%
%     model_noisy.noise.type = 'swn';
%     model_noisy.noise.lognoisevariance = log(NOISEVARIANCE);

model_noisy = model;

model_noisy.noise.type = 'swn';
model_noisy.noise.lognoisevariance = log(NOISEVARIANCE);

% Carry out the kriging prediction at locations xg.a

model_noisy = stk_setobs(model_noisy, xzi_noisy);
zp_noisy = stk_predict(model_noisy, xg);

% Display the result
xzp_noisy = stk_makedata(xg, zp_noisy);
figure(3)
stk_plot1d(xzi_noisy, xzg, xzp_noisy, 'Kriging prediction based on noisy observations');
