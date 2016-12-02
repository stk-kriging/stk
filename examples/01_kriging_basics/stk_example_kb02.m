% STK_EXAMPLE_KB02  Ordinary kriging in 1D with parameter estimation
%
% This example shows how to estimate covariance parameters and compute
% ordinary kriging predictions on a one-dimensional noiseless dataset.
%
% The model and data are the same as in stk_example_kb01, but this time the
% parameters of the covariance function are estimated using the Restricted
% Maximum Likelihood (ReML) method.
%
% See also: stk_example_kb01, stk_example_kb02n

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
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

stk_disp_examplewelcome


%% Dataset

% Load a 1D noiseless dataset
[xi, zi, ref] = stk_dataset_twobumps ('noiseless');

% The grid where predictions must be made
xt = ref.xt;

% Reference values on the grid
zt = ref.zt;

stk_figure ('stk_example_kb02 (a)');
stk_plot1d (xi, zi, xt, zt);  legend show;
stk_title  ('True function and observed data');


%% Specification of the model

% Define a model with a constant but unknown mean (ordinary kriging)
% and a Matern covariance function, the parameters of which will be
% estimated from the data.
model = stk_model ('stk_materncov_iso');


%% Parameter estimation

% Here, the parameters of the Matern covariance function are estimated
% by the REML (REstricted Maximum Likelihood) method.
model.param = stk_param_estim (model, xi, zi);

model


%% Carry out the kriging prediction and display the result

% Compute the kriging predictor (and the kriging variance) on the grid
zp = stk_predict (model, xi, zi, xt);

stk_figure ('stk_example_kb02 (b)');
stk_plot1d (xi, zi, xt, zt, zp);  legend show;
stk_title  ('Kriging prediction with estimated parameters');
stk_labels ('input variable x', 'response z');


%#ok<*NOPTS>

%!test stk_example_kb02;  close all;
