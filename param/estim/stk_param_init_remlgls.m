% STK_PARAM_ESTIM_REMLGS [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015, 2016, 2018, 2019, 2021 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
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

function [param, lnv] = stk_param_init_remlgls (model, xi, zi, other_params)

% Make sure than lnv is numeric
if ~ isfield (model, 'lognoisevariance')
    lnv = -inf;
    model.lognoisevariance = -inf;
else
    lnv = model.lognoisevariance;
    if ~ isnumeric (lnv)
        stk_error ('Non-numeric lnv is not supported.', 'IncorrectArgument');
    end
end

% Homoscedastic case ?
homoscedastic = isscalar (lnv);
noiseless = homoscedastic && (lnv == -inf);

% List of possible values for the ratio eta = sigma2_noise / sigma2
if ~ noiseless
    eta_list = 10 .^ (-6:3:0);
else
    eta_list = 0;
end

% Initialize parameter search
eta_best    = NaN;
k_best      = NaN;
sigma2_best = NaN;
aLL_best    = +Inf;

% Try all possible combinations of parameters from the lists
for eta = eta_list
    for k = 1:(size (other_params, 1))
        
        % First use sigma2 = 1.0
        param_ = [0.0, other_params(k, :)]';
        model.param = stk_set_optimizable_parameters (model.param, param_);
        
        if noiseless
            
            [~, sigma2] = stk_param_gls (model, xi, zi);
            if ~ (sigma2 > 0), continue; end
            log_sigma2 = log (sigma2);
            
        elseif homoscedastic && (isnan (lnv))  % Unknown noise variance
            
            model.lognoisevariance = log (eta);
            [~, sigma2] = stk_param_gls (model, xi, zi);
            if ~ (sigma2 > 0), continue; end
            log_sigma2 = log (sigma2);
            model.lognoisevariance = log  (eta * sigma2);
            
        else % Known variance(s)
            
            log_sigma2 = (mean (lnv)) - (log (eta));
            sigma2 = exp (log_sigma2);
            
        end
        
        % Now, compute the antilog-likelihood
        param_(1) = log_sigma2;
        model.param = stk_set_optimizable_parameters (model.param, param_);
        aLL = stk_param_relik (model, xi, zi);
        if ~ isnan(aLL) && (aLL < aLL_best)
            eta_best    = eta;
            k_best      = k;
            aLL_best    = aLL;
            sigma2_best = sigma2;
        end
    end
end

if isinf (aLL_best)
    errmsg = 'Couldn''t find reasonable parameter values... ?!?';
    stk_error (errmsg, 'AlgorithmFailure');
end

param = [log(sigma2_best), other_params(k_best, :)]';

if (isscalar (lnv)) && (isnan (lnv))
    % Homoscedatic case with unknown variance... Here is our estimate:
    lnv = log (eta_best * sigma2_best);
end

end % function
