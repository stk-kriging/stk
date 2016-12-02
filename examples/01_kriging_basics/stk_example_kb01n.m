% STK_EXAMPLE_KB01N  Ordinary kriging in 1D, with noisy data
%
% This example shows how to compute ordinary kriging predictions on a
% one-dimensional noisy dataset.
%
% The Gaussian Process (GP) prior is the same as in stk_example_kb01.
%
% The observation noise is Gaussian and homoscedastic (constant variance). 
% Its variance is assumed to be known.
%
% Note that the kriging predictor, which is the posterior mean of the GP,
% does NOT interpolate the data in this noisy example.
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

% Load a 1D noisy dataset (homoscedastic Gaussian noise)
[xi, zi, ref] = stk_dataset_twobumps ('noisy1');

% The grid where predictions must be made
xt = ref.xt;

% Reference values on the grid
zt = ref.zt;

stk_figure ('stk_example_kb01n (a)');
stk_plot1d (xi, zi, xt, zt);  legend show;
stk_title  ('True function and observed data');
stk_labels ('input variable x', 'response z');


%% Specification of the model
%
% We choose a Matern covariance with "fixed parameters" (in other  words, the
% parameters of the covariance function are provided by the user rather than
% estimated from data).
%

% The following line defines a model with a constant but unknown mean (ordinary
% kriging) and a Matern covariance function. (Some default parameters are also
% set, but we override them below.)
model = stk_model ('stk_materncov_iso');

% NOTE: the suffix '_iso' indicates an ISOTROPIC covariance function, but the
% distinction isotropic / anisotropic is irrelevant here since DIM = 1.

% Parameters for the Matern covariance function
% ("help stk_materncov_iso" for more information)
SIGMA2 = 0.5;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
model.param = log ([SIGMA2; NU; 1/RHO1]);

% It is assumed in this example that the variance of the noise is known
model.lognoisevariance = 2 * log (ref.noise_std);

model


%% Carry out the kriging prediction and display the result
%
% The result of a kriging predicition is provided by stk_predict() in an object
% zp of type stk_dataframe, with two columns: "zp.mean" (the kriging mean) and
% "zp.var" (the kriging variance).
%

% Carry out the kriging prediction at points xt
zp = stk_predict (model, xi, zi, xt);

% Display the result
stk_figure ('stk_example_kb01n (b)');
stk_plot1d (xi, zi, xt, zt, zp);  legend show;
stk_title  ('Kriging prediction based on noisy observations');
stk_labels ('input variable x', 'response z');


%#ok<*NOPTS>

%!test stk_example_kb01n;  close all;
