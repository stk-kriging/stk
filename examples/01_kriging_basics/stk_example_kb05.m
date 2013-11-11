% STK_EXAMPLE_KB05 show how to generate conditioned sample paths
%
% A Matern Gaussian process model is used, with constant but unknown mean
% (ordinary kriging) and known covariance parameters.
%
% Given noiseless observations from the unknown function, a batch of conditioned
% sample paths is drawn using the "conditioning by kriging" technique. In short,
% this means that unconditioned sample path are simulated first (using
% stk_generate_samplepaths), and then conditioned on the observations by kriging
% (using stk_conditioning).

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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb05');


%% Define a 1d test function

f = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
DIM = 1;            % dimension of the factor space
BOX = [-1.0; 1.0];  % factor space

NT = 400;  % nb of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f, xt);


%% Generate observations
%
% The objective is to construct an approximation of f and to simulate
% conditioned sample paths from NI observations. The observation locations
% are chosen as a subset of xt.
%

xi_ind = [1 20 90 200 300 350];  % indices of evaluation points in xt
xi = xt(xi_ind, 1);              % evaluation points
zi = stk_feval (f, xi);          % evaluation results


%% Specification of the model
%
% We choose a Matern covariance with "fixed parameters" (in other
% words, the parameters of the covariance function are provided by the user
% rather than estimated from data).
%

% The following line defines a model with a constant but unknown mean
% (ordinary kriging) and a Matern covariance function. (Some default
% parameters are also set, but we override them below.)
model = stk_model ('stk_materncov_iso');

% Parameters for the Matern covariance
% ("help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
model.param = log ([SIGMA2; NU; 1/RHO1]);


%% Generate (unconditional) sample paths

NB_PATHS = 10;

zsim = stk_generate_samplepaths (model, xt, NB_PATHS);

% Display the result
stk_subplot (2, 2, 1);  plot (xt, zsim, 'LineWidth', 2);  legend off;
stk_title ('Unconditional sample paths');
stk_labels ('input variable x', 'response z');


%% Carry out the kriging prediction and generate conditional sample paths

% Carry out the kriging prediction at points xt
[zp, lambda] = stk_predict (model, xi, zi, xt);

% Condition sample paths on the observations
zsimc = stk_conditioning (lambda, zi, zsim, xi_ind);

% Display the observations only
stk_subplot (2, 2, 2);
plot (xi, zi, 'ko', 'LineWidth', 3, 'MarkerSize', 4, 'MarkerFaceColor', 'k');
stk_title ('Observations');
stk_labels ('input variable x', 'response z');

% Display the conditional sample paths
stk_subplot (2, 2, 3);  plot (xt, zsimc, 'LineWidth', 2);  legend off;  hold on;
plot (xi, zi, 'ko', 'LineWidth', 3, 'MarkerSize', 4, 'MarkerFaceColor', 'k');
stk_title ('Conditional sample paths');
stk_labels ('input variable x', 'response z');

% Display the kriging and credible intervals
stk_subplot (2, 2, 4);  stk_plot1dsim (xi, zi, xt, zt, zp, zsimc);
stk_title ('Prediction and credible intervals');
stk_labels ('input variable x', 'response z');
