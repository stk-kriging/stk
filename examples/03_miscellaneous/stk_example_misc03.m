% STK_EXAMPLE_MISC03  How to deal with (known) seasonality

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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


%% Sinusoid + noise

t_obs = (0:0.05:12)';
S_obs = sin (t_obs + 0.3) + 0.1 * randn (size (t_obs));

stk_figure ('stk_example_misc03');  plot (t_obs, S_obs, 'k.');
stk_labels ('month number t', 'sunspots S');

t = (0:0.01:30)';


%% Gaussian process model with constant prior mean

model = stk_model ('stk_materncov52_iso');

% Initial guess for the parameters of the Matern covariance
[param0, lnv0] = stk_param_init (model, t_obs, S_obs, [], true);

% Estimate the parameters
[model.param, model.lognoisevariance] = stk_param_estim ...
    (model, t_obs, S_obs, param0, lnv0);

% Carry out the kriging prediction
S_posterior = stk_predict (model, t_obs, S_obs, t);

% Display the result
hold on;  plot (t, S_posterior.mean, 'r-');


%% Gaussian process model with seasonality

% Periodicity assumed to be known
T0 = 2 * pi;

% Here we use an EXPERIMENTAL feature of STK
model2 = stk_model ('stk_materncov52_iso');
model2.order = nan;
model2.lm = @(t)([ones(length(t),1) sin(2*pi*t/T0) cos(2*pi*t/T0)]);

% Initial guess for the parameters of the Matern covariance
[param0, lnv0] = stk_param_init (model2, t_obs, S_obs, [], true);

% Estimate the parameters
[model2.param, model2.lognoisevariance] = ...
    stk_param_estim (model2, t_obs, S_obs, param0, lnv0);

% Carry out the kriging prediction
S_posterior = stk_predict (model2, t_obs, S_obs, t);

% Display the result
hold on;  plot (t, S_posterior.mean, 'g-');


%% Display models

display (model)
display (model2)

%!test stk_example_misc03;  close all;
