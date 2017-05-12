function cstnoisevar0 = stk_param_init_lnv(cstnoisevar_def, model, xi, zi)
% cstnoisevar0 = stk_param_init_lnv(cstnoisevar_def, model, xi, zi)
%
% Furnish a default value for a constant noise variance of a model.
%
% - cstnoisevar_def : a default param, to select the good function, and
% furnish some defaut values;
% - model : the model where a parameter must be estimated;
% - (xi, zi) : the set of observation. xi : inputs; zi : outputs;

%% Check number of inputs
if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 4
    stk_error('Too few input arguments.', 'TooFewInputArgs');
end

%% Check size
if size(zi, 1) ~= size(xi, 1)
    stk_error('zi should have the same number of rows as xi.', 'IncorrectSize');
end

if size(zi, 2) ~= 1
    stk_error ('zi should be a column.', 'IncorrectSize');
end

%% Warn about special case: constant response
if (std (double (zi)) == 0)
    warning ('STK:stk_param_init_lnv:ConstantResponse', ['Constant- ' ...
        'response data: the output of stk_param_estim_lnv is likely ' ...
        'to be unreliable.']);
end

model.lognoisevariance = cstnoisevar_def;
cstnoisevar0 = cstnoisevar_def;
%% We will work with the ratio eta = sigma2_noise / sigma2
log_eta_min = -15;  % exp(-15) = 3e-7 approx  -> very small noise
log_eta_max = +15;  % exp(+15) = 3e+7 approx  -> very large noise
log_eta_list = linspace (log_eta_min, log_eta_max, 5);

%% Initialize parameter search
log_eta_best = nan;
aLL_best = +inf;

%% Find log-sigma2
covparam = model.param;
logsigma2 = stk_getLogSigma2(covparam);

%% Try all values from log_eta_list
for log_eta = log_eta_list
    model.lognoisevariance(1) = logsigma2 + log_eta;
    aLL = stk_param_relik (model, xi, zi);
    if (~ isnan (aLL)) && (aLL < aLL_best)
        log_eta_best = log_eta;
        aLL_best     = aLL;
    end
end

%% If not any best value
if isinf (aLL_best)
    errmsg = 'Couldn''t find reasonable parameter values... ?!?';
    stk_error (errmsg, 'AlgorithmFailure');
end

%% Return the best value
cstnoisevar0.lognoisevar = logsigma2 + log_eta_best;
end