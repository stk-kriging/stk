% STK_EXAMPLE_DOE07  SUR and EEM sequential designs for the estimation of 
% an excursion set, with noisy function evaluations.
%
% In this example, we consider the problem of estimating the set
%
%    Gamma = { x in X | f(x) > z_crit },
%
% where z_crit is a given value, and/or its volume.
%
% In a typical "structural reliability analysis" problem, Gamma would
% represent the failure region of a certain system, and its volume would
% correspond to the probability of failure (assuming a uniform distribution
% for the input).
%
% A Matern prior with unknown parameters is used for the function f, and
% the evaluations points are chosen sequentially using the sampling
% criteria described in [1] (SUR) and inspired from [2] (EEM).
%
% REFERENCE
%
%   [1] J. Bect, D. Ginsbourger, L. Li, V. Picheny and E. Vazquez (2012).
%       Sequential design of computer experiments for the estimation of a
%       probability of failure.  Statistics and Computing, 22(3), 773-793.
%
%   [2] R. Ait Abdelmalek-Lomenech, J. Bect, E. Vazquez (2025).
%       Bayesian Active Learning of (small) Quantile Sets through Expected
%       Estimator Modification.  ArXiv preprint arXiv:2506.13211.

% Copyright Notice
%
%    Copyright (C) 2025 CentraleSupelec
%
%    Author: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr>

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

stk_disp_examplewelcome


%% Problem definition

% 1D test function 
f = @(x) -stk_testfun_threehumpscamel(x);
x_domain = stk_hrect ([[-2; 2], [-2; 2]], {'x1', 'x2'});

% Threshold
z_crit =-1;

% Noise standard deviation
noise_std = 0.1;

%% Algorithms parameters

% Size of initial design and number of queried points
n_init = 10;
NB_ITER = 20;

% Size of the set for criteria approximation
n_points = 500;

%% GP priors

model_sur = stk_model (@stk_materncov_aniso, 2);
model_eem = stk_model (@stk_materncov_aniso, 2);

%% Performance evaluation and plots parameters

% Grid for evaluation and plotting
n_dim = 50;
grid = stk_sampling_regulargrid(n_dim^2, 2, x_domain);
x1_grid = unique(double(grid(:,1)));
x2_grid = unique(double(grid(:,2)));
z_grid = double(f(grid));

% Arrays for storing computation time and accuracy
time_sur = [];
time_eem = [];

accuracy_sur = [];
accuracy_eem = [];


%% Initial design of experiments

% Start with an initial design of n_init points, regularly spaced on the domain.
x_init = double(stk_sampling_maximinlhs(n_init, 2, x_domain));

% Values of the function on the initial design
z_init = f(x_init) + normrnd(0, noise_std, n_init, 1);

% Storing initial design and observations.
x_obs_sur = [x_init];
x_obs_eem = [x_init];
z_obs_sur = [z_init];
z_obs_eem = [z_init];



%% Sequential design of experiments

% Prepare monitoring plot
h_monit = stk_figure ('stk_example_doe07: Monitor');


for iter = 0:NB_ITER
    fprintf ('Iteration #%d\n', iter + 1);
    fprintf ('| Current sample size: n = %d\n', n_init + iter);

    % Candidate & approx. points
    xt = double(stk_sampling_randomlhs(n_points, 2, x_domain));
    zt = f(xt) + normrnd(0, noise_std, size(xt, 1), 1); %noisy evaluations

    % Fitting Gaussian process

    model_sur.lognoisevariance = nan;
    model_sur = stk_param_estim(model_sur, x_obs_sur, z_obs_sur);

    model_eem.lognoisevariance = nan;
    model_eem = stk_param_estim(model_eem, x_obs_eem, z_obs_eem);



    % SUR criterion
    crit_sur = zeros(size(xt,1), 1);
    tic;
    [z_pred_sur, ~, ~, Kpost_all] = stk_predict (model_sur, x_obs_sur, z_obs_sur, xt);

    for it = 1:size(xt,1)
        if ~ismember(xt(it,:), x_obs_sur, 'rows')
            K12 = Kpost_all(:, it);  % Posterior covariance between locations x and x_new
            K22 = Kpost_all(it, it);  % Posterior variance at xnew
            crit_sur(it) = mean(stk_pmisclass(z_crit, z_pred_sur, K12, K22));
        else
            crit_sur(it) = inf;
        end
    end

    time_sur = [time_sur, toc];

    % EEM criterion
    crit_eem = zeros(size(xt,1),1);
    tic;
    [z_pred_eem, ~, ~, Kpost_all] = stk_predict (model_eem, x_obs_eem, z_obs_eem, xt);

    for it = 1:size(xt,1)
        if ~ismember(xt(it,:), x_obs_eem, 'rows')
            K12 = Kpost_all(:, it);  % Posterior covariance between locations x and x_new
            K22 = Kpost_all(it, it);  % Posterior variance at xnew
            crit_eem(it) = stk_eem_excursion(z_crit, z_pred_eem.mean, K22, K12);
         else
            crit_eem(it) = -inf;
        end
    end

    time_eem = [time_eem, toc];


    % Pick the point where the criterion is minimal (SUR) or maximal (EEM)
    [crit_min, i_min] = min (crit_sur);
    [crit_max, i_max] = max (crit_eem);

    % Compute misclassification proportion
    pred_mean_sur = stk_predict(model_sur, x_obs_sur, z_obs_sur, grid).mean;
    pred_mean_eem = stk_predict(model_eem, x_obs_eem, z_obs_eem, grid).mean;
    accuracy_sur = [accuracy_sur, mean((pred_mean_sur > z_crit) == (z_grid > z_crit))];
    accuracy_eem = [accuracy_eem, mean((pred_mean_eem > z_crit) == (z_grid > z_crit))];

    %% Figure: upper panels

     % True function, true boundary (black line), estimated boundary (red line)
    % initial design (black dots), sequential design (red dots) and chosen
    % point (yellow dot) for SUR criterion.
    figure (h_monit);  subplot (2, 2, 1);  cla;
    pcolor(x1_grid, x2_grid', reshape(z_grid, n_dim, n_dim)); hold on;
    contour(x1_grid, x2_grid', reshape((z_grid >= z_crit), n_dim, n_dim), 'LineColor', 'black'); hold on
    contour(x1_grid, x2_grid', reshape((pred_mean_sur >= z_crit), n_dim, n_dim), 'LineColor', 'red'); hold on;
    scatter(x_obs_sur(1:n_init,1), x_obs_sur(1:n_init,2), "MarkerFaceColor", "black"); hold on;
    scatter(x_obs_sur(n_init+1:n_init+iter,1), x_obs_sur(n_init+1:n_init+iter,2), "MarkerFaceColor", "red"); hold on;
    scatter(xt(i_min,1), xt(i_min,2), 'MarkerFaceColor', 'y');
    colormap(flipud(parula))
    colorbar()
    title("SUR")

    % True function, true boundary (black line), estimated boundary (red line)
    % initial design (black dots), sequential design (red dots) and chosen
    % point (yellow dot) for EEM criterion.
    figure (h_monit);  subplot (2, 2, 2);  cla;
    pcolor(x1_grid, x2_grid', reshape(z_grid, n_dim, n_dim)); hold on;
    contour(x1_grid, x2_grid', reshape((z_grid >= z_crit), n_dim, n_dim), 'LineColor', 'black'); hold on;
    contour(x1_grid, x2_grid', reshape((pred_mean_eem >= z_crit), n_dim, n_dim), 'LineColor', 'red'); hold on;
    scatter(x_obs_eem(1:n_init,1), x_obs_eem(1:n_init,2), "MarkerFaceColor", "black"); hold on;
    scatter(x_obs_eem(n_init+1:n_init+iter,1), x_obs_eem(n_init+1:n_init+iter,2), "MarkerFaceColor", "red"); hold on;
    scatter(xt(i_max,1), xt(i_max,2), 'MarkerFaceColor', 'y');
    colormap(flipud(parula))
    colorbar()
    title("EEM")

    %% Figure: lower panels

    % Plot accuracy vs. number of queried points
    figure (h_monit);  subplot (2, 2, 3);  cla;
    plot(0:iter, accuracy_sur, 'LineWidth', 2, 'Color', "red"); hold on;
    plot(0:iter, accuracy_eem, 'LineWidth', 2, 'Color', "green");
    xlim([0, NB_ITER])
    xlabel("Queried points")
    ylim([min([accuracy_sur, accuracy_eem], [], 'all') 1])
    legend('SUR', 'EEM', 'Location','southeast')
    title("Accuracy")
    
    % Plot total computation time vs. number of queried points
    figure (h_monit);  subplot (2, 2, 4);  cla;
    plot(0:iter, cumsum(time_sur), 'LineWidth', 2, 'Color', "red"); hold on;
    plot(0:iter, cumsum(time_eem), 'LineWidth', 2, 'Color', "green");
    xlim([0, NB_ITER])
    xlabel("Queried points")
    legend('SUR', 'EEM', 'Location', 'southeast')
    title("Total computation time (s)")

    if (iter >= NB_ITER)
        break
    end

    % Add the new evaluation to the DoE
    x_obs_sur = [x_obs_sur; xt(i_min, :)];
    z_obs_sur = [z_obs_sur; zt(i_min, :)];
    x_obs_eem = [x_obs_eem; xt(i_max, :)];
    z_obs_eem = [z_obs_eem; zt(i_max, :)];

    drawnow ();
end


