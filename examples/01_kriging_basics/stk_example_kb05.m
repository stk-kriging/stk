% STK_EXAMPLE_KB05  Generation of conditioned sample paths
%
% A Matern Gaussian process model is used, with constant but unknown mean
% (ordinary kriging) and known covariance parameters.
%
% Given noiseless observations from the unknown function, a batch of conditioned
% sample paths is drawn using the "conditioning by kriging" technique. In short,
% this means that unconditioned sample path are simulated first (using
% stk_generate_samplepaths), and then conditioned on the observations by kriging
% (using stk_conditioning).
%
% Note: in this example, for pedagogical purposes, conditioned samplepaths are
% simulated in two steps: first, unconditioned samplepaths are simulated;
% second, conditioned samplepaths are obtained using conditioning by kriging.
% In practice, these two steps can be carried out all at once using
% stk_generate_samplepath (see, e.g., stk_example_kb09).
%
% See also: stk_generate_samplepaths, stk_conditioning, stk_example_kb09


% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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


%% Dataset

% Load a 1D noiseless dataset
[xi, zi, ref] = stk_dataset_twobumps ('noiseless');

% The grid where predictions must be made
xt = ref.xt;

% Reference values on the grid
zt = ref.zt;

% Indices of the evaluation points xi in the grid
xi_ind = ref.xi_ind;


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
stk_subplot (2, 2, 2);  stk_plot1d (xi, zi);
stk_title ('Observations');
stk_labels ('input variable x', 'response z');

% Display the conditional sample paths
stk_subplot (2, 2, 3);  plot (xt, zsimc, 'LineWidth', 2);  legend off;  hold on;
plot (xi, zi, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
stk_title ('Conditional sample paths');
stk_labels ('input variable x', 'response z');

% Display the kriging and credible intervals
stk_subplot (2, 2, 4);  stk_plot1d (xi, zi, xt, zt, zp, zsimc);
stk_title ('Prediction and credible intervals');
stk_labels ('input variable x', 'response z');


%!test stk_example_kb05;  close all;
