% STK_EXAMPLE_DOE06  Sequential design for the estimation of an excursion set
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
% A Matern 5/2 prior with known parameters is used for the function f, and
% the evaluations points are chosen sequentially using any of the sampling
% criterion described in [1] (see also [2], section 4.3).
%
% REFERENCE
%
%   [1] B. Echard, N. Gayton and M. Lemaire (2011).   AK-MCS: an active
%       learning reliability method combining Kriging and Monte Carlo
%       simulation.  Structural Safety, 33(2), 145-154.
%
%   [2] J. Bect, D. Ginsbourger, L. Li, V. Picheny and E. Vazquez (2012).
%       Sequential design of computer experiments for the estimation of a
%       probability of failure.  Statistics and Computing, 22(3), 773-793.

% Copyright Notice
%
%    Copyright (C) 2020 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

% Variables names
input_name = 'x';
output_name = 'z';

% 1D test function
f = @(x)(x .* (sin (24 * x .^ 0.7) - 0.3));
x_domain = stk_hrect ([0; 1], {input_name});

% Threshold
z_crit = 0.15;


%% Monte Carlo

% Choose a MC sample size that would produce an estimate of the volume of
% the set with standard deviation <= 0.005 (0.5% of the total volume).
MC_target_std = 0.005;
MC_sample_size = 0.25 / (MC_target_std ^ 2);  % = 10 000

% Draw a MC sample in the input domain
x_MC = stk_sampling_randunif (MC_sample_size, [], x_domain);
x_MC.rownames = arrayfun (@(i)(sprintf ('MC point #%05d', i)), ...
                          1:MC_sample_size, 'UniformOutput', false)';
x_MC = sort (x_MC, 'ascend');  % Better for plotting

% Compute the MC estimator, which will be our reference value for the
% volume.  Note that here we evaluate f on the entire MC set, but ONLY to
% get the reference value (we do not use these evaluations below !).
z_MC = stk_feval (f, x_MC);
z_MC.colnames = {output_name};
vol_ref = mean (z_MC > z_crit);

fprintf ('Volume (reference value): %.2f%%\n', vol_ref * 100);


%% Plot problem

% Spatial discretization (used for plotting only)
grid_size = 1000;
x_grid = stk_sampling_regulargrid (grid_size, [], x_domain);
x_grid.rownames = arrayfun ...
    (@(i)(sprintf ('grid point #%03d', i)), 1:grid_size, 'UniformOutput', false)';

% Values of the response on the grid
z_grid = stk_feval (f, x_grid);
z_grid.colnames = {output_name};

stk_figure ('stk_example_doe06: Ground truth');
plot (x_grid, z_grid, 'b');  hold on;
b = z_grid > z_crit;  tmp = z_grid;  tmp(~b) = nan;
plot (x_grid, tmp, 'r', 'LineWidth', 3);  clear tmp;
plot (xlim, z_crit * [1 1], 'r--');
title ('Groung truth');
legend ('z = f(x), below z_{crit}', 'z = f(x), above z_{crit}', ...
        'z_{crit}', 'Location', 'SouthWest');


%% Initial design of experiments

% Start with an initial design of N0 points, regularly spaced on the domain.
n_init = 4;
x_init = stk_sampling_regulargrid (n_init, [], x_domain);
x_init.rownames = arrayfun ...
    (@(i)(sprintf ('initial design #%d', i)), 1:n_init, 'UniformOutput', false)';

% Values of the function on the initial design
z_init = stk_feval (f, x_init);
z_init.colnames = {output_name};

data_init = [x_init, z_init];  display (data_init);


%% Specification of a Gaussian process prior

% Same as in stk_example_doe03 (read explanation there).
model = stk_model (@stk_materncov52_iso);
SIGMA2 = 4.0 ^ 2;  % Variance parameter
RHO = 0.5;         % Length scale (range) parameter
model.param = log ([SIGMA2; 1/RHO]);


%% Sequential design of experiments

% Start with the initial design defined above
data = data_init;

% Iteration number & maximal number of points to be added adaptively
NB_ITER = 50;

% Upper bound on the posterior std of the volume & target accuracy
vol_std_ub = +inf;
vol_std_tol = MC_target_std * 0.1;

% Prepare monitoring plot
h_monit = stk_figure ('stk_example_doe06: Monitor');

% Record history of volume estimates & misclassification counts
vol_hist = nan (n_init - 1, 1);
nmisclass_hist = nan (n_init - 1, 1);

% Choose which volume estimator to use: 'plugin' or 'bayes'
% (this does not impact the sequence of points that we choose)
vol_estim_type = 'plugin';

for iter = 0:NB_ITER
    fprintf ('Iteration #%d\n', iter + 1);
    fprintf ('| Current sample size: n = %d\n', n_init + iter);

    % Trick: add a small "regularization" noise to our model
    model.lognoisevariance = log (SIGMA2 * 1e-12);

    % Carry out the kriging prediction
    M_post = stk_model_gpposterior (model, data.x, data.z);
    z_MC_pred = stk_predict (M_post, x_MC);

    % Count misclassified samples
    % (this is for educational purposes: we are not supposed to know z_MC)
    nmisclass = sum ((z_MC_pred.mean > z_crit) ~= (z_MC > z_crit));
    nmisclass_hist = [nmisclass_hist; nmisclass];  %#ok<AGROW>

    % Compute "maximal probability of misclassification" criterion
    % (equivalent to EGL's criterion, but better-looking on plots)
    [p, q] = stk_distrib_normal_cdf ...
        (z_crit, z_MC_pred.mean, sqrt (z_MC_pred.var));
    crit_val = min (p, q);

    % Compute volume estimate
    if strcmp (vol_estim_type, 'bayes')
        vol_estim = mean (q);
    else
        assert (strcmp (vol_estim_type, 'plugin'));
        vol_estim = mean (z_MC_pred.mean > z_crit);
    end
    vol_hist = [vol_hist; vol_estim];  %#ok<AGROW>
    fprintf ('| Volume estimate (%s): %.5f  [ref: %.5f]\n', ...
             vol_estim_type, vol_estim, vol_ref);

    % Compute an upper-bound on the posterior std of the estimator
    if strcmp (vol_estim_type, 'bayes')
        vol_std_ub = sqrt (mean (p .* q));
    else
        vol_std_ub = sqrt (mean (min (p, q)));
    end
    fprintf ('| Upper-bound on posterior std: %.4e  [target: %.3e]\n', ...
             vol_std_ub, vol_std_tol);

    % Pick the point where the criterion is maximal
    [crit_max, i_max] = max (crit_val);

    % Figure: upper panel
    figure (h_monit);  stk_subplot (2, 1, 1);  cla;
    stk_plot1d (data.x, data.z, x_grid, z_grid, stk_predict (M_post, x_grid));
    xlim (x_domain);  hold on;  plot (xlim, z_crit * [1 1], 'r--');
    plot (x_MC(i_max), z_MC_pred.mean(i_max), 'ro', 'MarkerFaceColor', 'y');

    % Figure: lower panel
    stk_subplot (2, 1, 2);  cla;
    plot (x_MC, crit_val, 'Linewidth', 2);  xlim (x_domain);  hold on;
    plot (x_MC(i_max), crit_max, 'ro', 'MarkerFaceColor', 'y');
    stk_ylabel ('criterion');

    if (iter >= NB_ITER) || (vol_std_ub <= vol_std_tol)
        break
    end

    % Add the new evaluation to the DoE
    data = [data; [x_MC(i_max, :), z_MC(i_max, :)]];  %#ok<AGROW>

    drawnow ();  % pause (0.5);
end

% Display full history: DoE + volume estimates
vol_err = vol_hist - vol_ref;
estim_history = stk_dataframe ([vol_hist vol_err nmisclass_hist], ...
                               {'vol_estim' 'vol_err', 'nmisclass'});
history = [data estim_history];  display (history);

% Display final result
fprintf ('Final result:\n');
fprintf ('| Number of evaluations: %d + %d = %d.\n', ...
         n_init, iter, n_init + iter);
fprintf ('| Volume estimate (%s): %.4f%%  [ref: %.4f%%]\n\n', ...
         vol_estim_type, vol_estim * 100, vol_ref * 100);


%#ok<*SPERR,*UNRCH>

%!test stk_example_doe06;  close all;
