% STK_EXAMPLE_KB09  Generation of sample paths conditioned on noisy observations
%
% A Matern Gaussian process model is used, with constant but unknown mean
% (ordinary kriging) and known covariance parameters.
%
% Given noisy observations from the unknown function, a batch of conditioned
% sample paths is drawn using the "conditioning by kriging" technique
% (stk_generate_samplepaths function).
%
% See also: stk_generate_samplepaths, stk_conditioning, stk_example_kb05

% Copyright Notice
%
%    Copyright (C) 2015, 2016, 2018 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb09');


%% Dataset

% Load a 1D noisy dataset (heteroscedastic Gaussian noise)
[xi, zi, ref] = stk_dataset_twobumps ('noisy2');

% The grid where predictions must be made
xt = ref.xt;

% Reference values on the grid
zt = ref.zt;


%% Gaussian process model

% Define a model with a constant but unknown mean (ordinary kriging)
% and a Matern 5/2 covariance function, the parameters of which will be
% estimated from the data.
model = stk_model (@stk_materncov52_iso);

% Variance of the heteroscedastic noise (assumed to be known).
% Note that ref.noise_std is a *vector* in this case.
model.lognoisevariance = 2 * log (ref.noise_std);

% ReML parameter estimation
model.param = stk_param_estim (model, xi, zi);


%% Generate conditional sample paths

NB_PATHS = 20;

zp = stk_predict (model, xi, zi, xt);

z_sim_cond = stk_generate_samplepaths (model, xi, zi, xt, NB_PATHS);

% Display the result
stk_plot1d (xi, zi, xt, zt, zp, z_sim_cond);
h = stk_legend ();  set (h, 'Location', 'NorthWest');
stk_title ('Prediction and credible intervals');
stk_labels ('input variable x', 'response z');


%!test stk_example_kb09;  close all;
