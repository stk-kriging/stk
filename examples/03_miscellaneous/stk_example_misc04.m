% STK_EXAMPLE_MISC04  Pareto front simulation
%
% DESCRIPTION
%
%   We consider a bi-objective optimization problem, where the objective
%   functions are modeled as a pair of independent stationary Gaussian
%   processes with a Matern 5/2 anisotropic covariance function.
%
%   Figure (a): represent unconditional realizations of the Pareto front and
%      and estimate of the probability of being non-dominated at each point
%      of the objective space.
%
%   Figure (b): represent conditional realizations of the Pareto front and
%      and estimate of the posteriorior probability of being non-dominated
%      at each point of the objective space.
%
% EXPERIMENTAL FUNCTION WARNING
%
%    This script uses the stk_plot_probdom2d function, which is currently
%    considered an experimental function.  Read the help for more information.
%
% REFERENCE
%
%  [1] Michael Binois, David Ginsbourger and Olivier Roustant,  Quantifying
%      uncertainty on Pareto fronts with Gaussian Process conditional simu-
%      lations,  European J. of Operational Research, 2043(2):386-394, 2015.
%
% See also: stk_plot_probdom2d

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

stk_disp_examplewelcome;


%% Objective functions

DIM = 2;
BOX = [[0; 5] [0; 3]];

f1 = @(x) 4 * x(:,1) .^ 2 + 4 * x(:,2) .^ 2;
f2 = @(x) (x(:,1) - 5) .^ 2 + (x(:,2) - 5) .^ 2;


%% Data

n_obs = 10;

x_obs = stk_sampling_maximinlhs (n_obs, [], BOX);

z_obs = zeros (n_obs, 2);
z_obs(:, 1) = f1 (x_obs.data);  % Remark: f1 (x_obs) should be OK...
z_obs(:, 2) = f2 (x_obs.data);  %         ... but see Octave bug #49267 


%% Stationary GP models

model1 = stk_model ('stk_materncov52_aniso', DIM);
model1.param = stk_param_estim (model1, x_obs, z_obs(:, 1));

model2 = stk_model ('stk_materncov52_aniso', DIM);
model2.param = stk_param_estim (model2, x_obs, z_obs(:, 1));

stk_figure ('stk_example_misc04 (a)');

stk_plot_probdom2d (model1, model2, BOX);


%% Conditionned GP models

stk_figure ('stk_example_misc04 (b)');

stk_plot_probdom2d ( ...
    stk_model_gpposterior (model1, x_obs, z_obs(:, 1)), ...
    stk_model_gpposterior (model2, x_obs, z_obs(:, 2)), BOX);


%!test stk_example_misc04;  close all;
