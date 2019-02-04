% STK_EXAMPLE_MISC06  Estimation of parameters using various criteria
%
% FIXME: This example is not mature enough to be released
%
% This example compares different criteria to estimate the
% hyper-parameters of a Gaussian process model. Four criteria are compared:
%   * Restricted likelihood (stk_param_relik)
%   * Leave-one-out Mean Square Error (stk_param_loomse)
%   * Posterior distribution (stk_param_relik)
%   * Leave-one-out Predictive Variance Criterion (stk_param_loopvc)
%
% See also: stk_example_kb02, stk_example_misc02, stk_param_relik, stk_param_loomse

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%    Copyright (C) 2018 LNE
%
%    Author:  Remi Stroh  <remi.stroh@lne.fr>

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


%% Initial data

% Function
f = @stk_testfun_twobumps;
rout = 5;

% Input domains
bnd = stk_hrect ([-1; 1], {'x'});

% Measure of the input domains
dim = size (bnd, 2);
bin = diff (bnd);

% Reality
nt = 101;
xt = stk_sampling_regulargrid (nt, dim, bnd);
zt = f(xt);

% Observation functions
noise = 0.0;
% noise = 0.14;
is_noise = (noise ~= 0.0);
fobs = @(x)(f(x) + noise * randn (size (x, 1), 1));

% Observations
ni = 6 * dim * (1 + is_noise);
xi = stk_sampling_maximinlhs (ni, dim, bnd + [1; -1] * (bin/5));
zi = fobs(xi);

% Correct the value of sigma2 for leave-one-out criteria?
correct_sig2_loo = false;


%% Prior distribution

% Prior on log(sigma^2)
mean_prior_param = 2 * log (rout);
var_prior_param  = log(100) ^ 2;

% Prior on log(rho)
var_logrho = log(10) ^ 2;
mean_prior_param = [mean_prior_param; -log(mean(bin) / 2)];
var_prior_param  = [var_prior_param ; var_logrho];

% Prior on log(lambda)
if is_noise
    mean_prior_lnv = 2 * log(rout);
    var_prior_lnv = log(100) ^ 2;
end


%% Compute prediction for each criterion

% List of criterion
list_crit = {@stk_param_relik, @stk_param_loomse, ...
    @stk_param_relik, @stk_param_loopvc};
nb_crit = length (list_crit);

is_first_relik = true;  % To distinguish between likelihood and log-posterior

% Number of sub-plot
sub1 = ceil (sqrt (nb_crit));
sub2 = sub1 - 1;
if nb_crit > sub1*sub2
    sub2 = sub2 + 1;
end

% Best parameters according to criteria
best_params = [];

stk_figure ('stk_example_misc06 (a): Predictions');
for estim = 1:nb_crit
    
    % Extract criterion of optimization
    crit = list_crit{estim};
    name_crit = func2str(crit);
    
    % Complementary informations
    is_prior = false;                                 % Add prior ?
    is_loo = ~ isempty (strfind (name_crit, 'loo'));  %#ok<STREMP>
    
    if strcmp (name_crit, 'stk_param_relik')
        if is_first_relik
            % If it is the first time we use relik, do nothing, just indicate it
            is_first_relik = false;
        else
            % Else, use prior, change the name of the criterion
            is_prior = true;
            name_crit = 'stk_param_post';
        end
    end
    
    disp (['# Criterion: ', name_crit]);
    name_crit = strrep (name_crit, '_', '-');  % To be displayed in the figure
    
    % Define the model
    model = stk_model (@stk_materncov52_iso, dim);
    model.lm = stk_lm_constant;
    
    % Noise
    if is_noise
        model.lognoisevariance = nan;
    end
    
    % Prior distribution
    if is_prior
        model.prior.mean = mean_prior_param;
        model.prior.invcov = diag(1./var_prior_param);
        
        if is_noise
            model.noiseprior.mean = mean_prior_lnv;
            model.noiseprior.var = 1./var_prior_lnv;
        end
    end
    
    % Initialize parameters
    [par0, lnv0] = stk_param_init (model, xi, zi, bnd);
    if correct_sig2_loo && is_loo
        % If is loo, check the problem of the parameter sigma^2
        model.param = par0;
        model.lognoisevariance  = lnv0;
        [~, s2] = stk_param_gls (model, xi, zi);
        par0(1) = par0(1) + log(s2);
        if is_noise
            lnv0 = lnv0 + log(s2);
        end
    end
    
    % Estimate parameters
    if is_noise
        [par_opt, lnv_opt] = stk_param_estim (model, xi, zi, par0, lnv0, crit);
    else
        % If no noise, lnv0 must be empty
        [par_opt, lnv_opt] = stk_param_estim (model, xi, zi, par0, [], crit);
    end
    
    % Set optimal parameters
    if correct_sig2_loo && is_loo
        % If is loo, check the problem of the parameter sigma^2
        model.param = par_opt;
        model.lognoisevariance = lnv_opt;
        [~, s2] = stk_param_gls(model, xi, zi);
        par_opt(1) = par_opt(1) + log(s2);
        if is_noise
            lnv_opt = lnv_opt + log(s2);
        end
    end
    
    model.param = par_opt;
    model.lognoisevariance  = lnv_opt;
    
    % Display parameters
    fprintf ('\nModel:\n');
    disp (['Covariance function: ', func2str(model.covariance_type)]);
    disp (['sigma = ', num2str(exp ( par_opt(1, :) * 0.5))]);
    disp (['  rho = ', num2str(exp (-par_opt(2, :)      ))]);
    
    % Add the noise
    if stk_isnoisy (model)
        disp (['noise = ', num2str(exp (lnv_opt * 0.5))]);
    end
    
    % Save the parameters
    if is_noise
        best_params = cat (2, best_params, [model.param; model.lognoisevariance]);
    else
        best_params = cat (2, best_params, model.param);
    end
    
    
    %% Compare values of criteria
    
    % Remove prior
    if is_prior
        model = rmfield(model, 'prior');
        if is_noise
            model = rmfield(model, 'noiseprior');
        end
    end
    
    % Compute restricted likelihood
    relik = stk_param_relik (model, xi, zi);
    
    % Compute leave-one-out mean square error
    loo = stk_param_loomse (model, xi, zi);
    
    % Compute leave-one-out predictive variance
    lop = stk_param_loopvc (model, xi, zi);
    
    % Add prior
    model.prior.mean = mean_prior_param;
    model.prior.invcov = diag(1./var_prior_param);
    if is_noise
        model.noiseprior.mean = mean_prior_lnv;
        model.noiseprior.var  = 1./var_prior_lnv;
    end
    
    % Compute log-posterior distribution
    post = stk_param_relik (model, xi, zi);
    
    % Display
    fprintf ('\nValues of the criteria:\n');
    disp (['   Anti log-restricted likelihood: ', num2str(relik, 4)]);
    disp (['  Leave-One-Out Mean Square Error: ', num2str(loo,   4)]);
    disp (['               Anti log-posterior: ', num2str(post,  4)]);
    disp (['Leave-One-Out Predictive Variance: ', num2str(lop,   4)]);
    
    % Prediction
    zp = stk_predict (model, xi, zi, xt);
    
    
    %% Figure
    
    stk_subplot (sub1, sub2, estim);
    stk_plot1d (xi, zi, xt, zt, zp);
    
    % Threshold
    hold on;  plot (double (bnd), [0, 0], 'k-');
    
    % Bounds
    xlim (double (bnd));
    
    % Labels
    stk_xlabel ('x');
    stk_ylabel ('Z');
    stk_title (['Criterion: ', name_crit]);
    
    fprintf ('\n\n');
end
