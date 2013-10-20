% STK_EXAMPLE_KB02 constructs an ordinary kriging approximation in 1D, with
% covariance parameters estimated from the data.
%
% A Matern covariance function is used for the Gaussian Process (GP) prior. The
% parameters of this covariance function are estimated using the Restricted
% Maximum Likelihood (ReML) method.
%
% The mean function of the GP prior is assumed to be constant and unknown.
%
% The example can be run either with noisy data or with noiseless data,
% depending on the value of the NOISY flag (the default is false, i.e.,
% noiseless data).
%
% See also: stk_example_kb01, stk_example_kb03

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

% Use verbose output
save_verbosity = stk_options_get ('stk_dataframe', 'disp_format');
stk_options_set ('stk_dataframe', 'disp_format', 'verbose');


%% DEFINE A 1D TEST FUNCTION

f = @(x)(- (0.8 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
DIM = 1;               % Dimension of the factor space
BOX = [-1.0; 1.0];     % Factor space

NOISY = false;         % Choose either a noiseless or a noisy demo.
if ~ NOISY             % NOISELESS DEMO ...
    NI = 6;            %   NI = nb of evaluations that will be used
    NOISESTD = 0.0;    %      noiseless!
else                   % OR NOISY DEMO ?
    NI = 20;           %   NI = nb of evaluations that will be used
    NOISESTD = 0.1;    %   NOISESTD = std deviation of the observation noise
end                    %


%% "MAXIMIN LHS" SAMPLING PLAN & CORRESPONDING EVALUATIONS
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a "maximin LHS" design.
%

NITER = 5;  % number of random designs generated in stk_sampling_maximinlhs()

xi = stk_sampling_maximinlhs (NI, DIM, BOX, NITER);  % evaluation points
% xi = stk_sampling_randunif (NI, DIM, BOX);
zi = stk_feval (f, xi);                              % evaluation results

if NOISY,
    zi = zi + NOISESTD * randn (NI, 1);
end

xzi = stk_makedata(xi, zi);


%% SPECIFICATION OF THE MODEL
%
% We choose a Matern covariance, the parameters of which will be estimated from
% the data.
%

% The following line defines a model with a constant but unknown mean (ordinary
% kriging) and a Matern covariance function. (Some default parameters are also
% set, but they will be replaced below by estimated parameters.)
model = stk_model ('stk_materncov_iso');

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

if ~ NOISY,
    % Noiseless case: set a small "regularization" noise	
    model.noise.cov = stk_homnoisecov (1e-6 ^ 2);
else
    % Otherwise, set the variance of the noise (assumed to be known)
	model.noise.cov = stk_homnoisecov (NOISESTD ^ 2);
end

% Estimate the paramaters (the noise variance is not estimated)
model.randomprocess.priorcov.param = stk_param_estim (model);

model  %#ok<NOPTS>


%% CARRY OUT KRIGING PREDICTION AND DISPLAY RESULTS

NT = 400;                                      % Number of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);  % Generate a regular grid
zt = stk_feval (f, xt);                        % Values of f on the grid
ot = stk_makedata(xt, zt);

% Compute the kriging predictor (and the kriging variance) on the grid
zp  = stk_predict (model, xt);
xzp = stk_makedata (xt, zp);

% Visualisation
stk_plot1d (xzi, ot, xzp);
t = sprintf('%s %.3e', 'Kriging prediction with noise std', NOISESTD);
title(t);  set(gcf, 'Name', t);
xlabel ('x');  ylabel ('z');


%% Cleanup

% Restore output verbosity
stk_options_set ('stk_dataframe', 'disp_format', save_verbosity);
