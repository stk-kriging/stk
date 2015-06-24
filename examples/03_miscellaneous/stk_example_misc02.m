% STK_EXAMPLE_MISC02  How to use priors on the covariance parameters
%
% A Matern covariance in dimension one  is considered as an example.  A Gaussian
% prior is used for all three parameters: log-variance, log-regularity  and log-
% inverse-range.  The corresponding parameter estimates are Maximum A Posteriori
% (MAP) estimates or, more precisely, Restricted MAP (ReMAP) estimates.
%
% Several values for the variance of the prior  are successively considered,  to
% illustrate the effect of this prior variance on the parameter estimates.  When
% the variance is small, the MAP estimate is close to the mode of the prior.  On
% the other hand, when the variance is large,  the prior becomes "flat"  and the
% MAP estimate is close to the ReML estimate (see figure b).

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
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

stk_disp_examplewelcome


%% DEFINE AN ARTIFICIAL ONE-DIMENSIONAL DATASET

DIM = 1;            % dimension of the factor space
BOX = [0.0; 1.0];   % factor space

xi = [0.25; 0.26; 0.50; 0.60];
zi = [1.00; 1.10; 0.20; 0.35];


%% SPECIFICATION OF THE MODEL & REML ESTIMATION

model = stk_model ('stk_materncov_iso');

% small "regularization noise".
model.lognoisevariance = 2 * log (1e-6);

% Mode of the prior on the parameters of the Matern covariance
% (also serves as an initial guess for the optimization)
SIGMA2 = 1.0;  % variance parameter
NU     = 2.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
param0 = log ([SIGMA2; NU; 1/RHO1]);

% Estimate covariance parameters (without prior)
model.param = stk_param_estim (model, xi, zi, param0);
param_opt_reml = model.param;


%% EXPERIMENT WITH SEVERAL VALUES FOR PRIOR VARIANCES

std_list = [10 1 0.2 0.01];

NT = 400; % nb of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);

stk_figure ('stk_example_misc02 (a)');

param_opt = zeros (length (param0), length (std_list));
for k = 1:length (std_list),
    
    % Prior on the parameters of the Matern covariance
    model.prior.mean = param0;
    model.prior.invcov = eye (length (param0)) ./ (std_list(k)^2);
    
    % Estimate covariance parameters (with a prior)
    model.param = stk_param_estim (model, xi, zi, param0);
    param_opt(:, k) = model.param;
    
    % Carry out kriging prediction
    zp = stk_predict (model, xi, zi, xt);
    
    % Plot predicted values and pointwise confidences intervals
    stk_subplot (2, 2, k);  stk_plot1d (xi, zi, xt, [], zp);
    stk_labels ('input x', 'predicted output z');
    stk_title (sprintf ('prior std = %.2f', std_list(k)));
end


%% FIGURE: ESTIMATED PARAMETER VERSUS PRIOR STD

stk_figure ('stk_example_misc02 (b)');

param_name = {'SIGMA2', 'NU', '1/RHO'};

for j = 1:3,
    
    stk_subplot (2, 2, j);
    
    % estimated parameter versus prior std
    h = semilogx (std_list, exp (param_opt(j, :)), 'ko-');
    set (h, 'LineWidth', 2, 'MarkerFaceColor', 'y');
    stk_labels ('prior std', param_name{j});
    
    % add an horizontal line showing the value of REML estimation
    hold on;  semilogx (xlim, exp (param_opt_reml(j)) * [1 1], 'r--');
    
    % add a second horizontal line showing the mode of the prior
    hold on;  semilogx (xlim, exp (param0(j)) * [1 1], 'b--');
    
    % adjust ylim
    yy = exp ([param_opt(j, :) param_opt_reml(j) param0(j)]);
    ylim_min = min (yy);  ylim_max = max (yy);  delta = ylim_max - ylim_min;
    ylim ([ylim_min - 0.05*delta ylim_max + 0.05*delta]);
    
end

if ~ strcmp (graphics_toolkit (), 'gnuplot')
    h1 = legend ('MAP estimates', 'REML estimate', 'mode of the prior');
    h2 = stk_subplot (2, 2, 4);  axis off;
    set (h1, 'Position', get (h2, 'Position'));
end


%!test stk_example_misc02;  close all;
