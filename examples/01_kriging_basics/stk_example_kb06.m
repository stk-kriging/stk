% STK_EXAMPLE_KB06 compares ordinary kriging and kriging with a linear trend
%
% The same dataset is analyzed using two variants of kriging.
%
% The left panel shows the result of ordinary kriging, in other words,  Gaussian
% process interpolation  assuming a constant (but unknown) mean. The right panel
% shows the result of adding a linear trend in the mean of the Gaussian process.
%
% The difference with the left plot is clear in extrapolation: the first predic-
% tor exhibits a  "mean reverting"  behaviour,  while the second one captures an
% increasing trend in the data.

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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb06');


%% Preliminaries

DIM = 1;                                       % Dimension of the factor space
BOX = [-2.0; 2.0];                             % Factor space
NT = 1e3;                                      % Number of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);  % Construct a regular grid


%% Data

xi = stk_dataframe ([0.00; 0.10; 0.20], {'x'});  % Evaluation points
zi = stk_dataframe ([0.00; 0.09; 0.21], {'z'});  % Evaluation results


%% Default parameters for the Matern covariance

model = stk_model ('stk_materncov_iso', DIM);
xzi = stk_makedata(xi, zi);  model = stk_setobs (model, xzi);

% Parameters used as initial values for stk_param_estim()
model.randomprocess.priorcov.sigma2 = 1.0;  % variance parameter
model.randomprocess.priorcov.nu     = 2.0;  % regularity parameter
model.randomprocess.priorcov.rho    = 0.4;  % scale (range) parameter

model.noise.cov = stk_homnoisecov (1e-10 ^ 2);


%% Ordinary kriging (constant mean)

model1 = model;
model1.randomprocess.priormean = stk_lm ('constant');
model1.randomprocess.priorcov.param = stk_param_estim (model1);

% Carry out kriging prediction
zp = stk_predict (model1, xt);

% Plot the result
figure;  subplot (1, 2, 1);
stk_plot1d (xzi, [], stk_makedata (xt, zp));
title ('Ordinary kriging');  ylim ([-5 5]);


%% Linear trend (aka "universal kriging")

model2 = model;
model2.randomprocess.priormean = stk_lm ('affine');
model2.randomprocess.priorcov.param = stk_param_estim (model2);

% Carry out kriging prediction
zp = stk_predict (model, xt);

% Plot the result
subplot (1, 2, 2);  stk_plot1d (xzi, [], stk_makedata (xt, zp));
title ('Kriging with linear trend');  ylim ([-5 5]);
