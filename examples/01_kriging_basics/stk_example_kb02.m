% stk_example_kb02.m
%
% Construct a kriging approximation from a set of observations, in 1D. In
% this example, the parameters of the model are estimated from the observations.
%
% See also: stk_example_kb01, stk_example_kb03

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
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


%% DEFINE A 1D TEST FUNCTION

f = @(x)( -(0.8*x + sin(5*x+1) + 0.1*sin(10*x)) );  % Define a 1D test function
DIM = 1;                                            % Dimension of the factor space
BOX = [-1.0; 1.0];                                  % Factor space

NOISY = false;         % Choose either a noiseless or a noisy demo.
if ~NOISY              % NOISELESS DEMO ...
    NI = 6;            %      NI = nb of evaluations that will be used
    NOISESTD = 0.0;    %      noiseless!
else                   % OR NOISY DEMO ?
    NI = 20;           %      NI = nb of evaluations that will be used
    NOISESTD = 0.1;    %      NOISESTD = standard deviation of the observation noise
end                    %


%% "MAXIMIN LHS" SAMPLING PLAN & CORRESPONDING EVALUATIONS
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a "maximin LHS" design.
%

NITER = 5; % number of random designs generated in stk_sampling_maximinlhs()

xi = stk_sampling_maximinlhs(NI, DIM, BOX, NITER);  % Evaluation points
%xi = stk_sampling_randunif(NI, DIM, BOX);
zi = stk_feval(f, xi);                              % Evaluation results

if NOISY,
    zi.a = zi.a + NOISESTD * randn(NI, 1);
    % (don't forget that the data is in the ".a" field!)
end

xzi = stk_makedata(xi, zi);


%% SPECIFICATION OF THE MODEL
%
% We choose a Matern covariance, the parameters of which will be estimated from the data.
%

% The following line defines a model with a constant but unknown mean (ordinary
% kriging) and a Matern covariance function. (Some default parameters are also
% set, but they will be replaced below by estimated parameters.)
model = stk_model('stk_materncov_iso');

% Set observations for the model
model = stk_setobs(model, xzi);


%% ESTIMATION OF THE PARAMETERS OF THE COVARIANCE
%
% Here, the parameters of the Matern covariance function are estimated by the
% REML (REstricted Maximum Likelihood) method using stk_param_estim().
%

% % Initial guess for the parameters of the Matern covariance
% param0 = stk_param_init(model, BOX, NOISY);

% Alternative: user-defined initial guess for the parameters of the Matern covariance
% (see "help stk_materncov_iso" for more information)
model.randomprocess.priorcov.sigma2 = 1.0;  % variance parameter
model.randomprocess.priorcov.nu     = 4.0;  % regularity parameter
model.randomprocess.priorcov.rho    = 0.4;  % scale (range) parameter

if ~NOISY, % noiseless case
	model.noise.cov = stk_homnoisecov(1e-6^2); % small "regularization" noise (fixed)
    model.randomprocess.priorcov.param = stk_param_estim(model);
else
	model.noise.cov = stk_homnoisecov(NOISESTD^2); % NOISESTD is assumed to be known
    model.randomprocess.priorcov.param = stk_param_estim(model);
end


%% CARRY OUT KRIGING PREDICTION AND DISPLAY RESULTS

NT = 400;                                     % Number of points in the grid
xt = stk_sampling_regulargrid(NT, DIM, BOX);  % Generate a regular grid of size NT
zt = stk_feval(f, xt);                        % True value of the function on the grid
ot = stk_makedata(xt, zt);

% Compute the kriging predictor (and the kriging variance) on the grid
zp  = stk_predict(model, xt);
xzp = stk_makedata(xt, zp);

% Display the result
stk_plot1d(xzi, ot, xzp);
t = sprintf('%s %.3e', 'Kriging prediction with noise std', NOISESTD);
title(t); set(gcf, 'Name', t);
