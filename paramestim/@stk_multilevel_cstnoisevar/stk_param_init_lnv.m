function ml_nv0 = stk_param_init_lnv(ml_nv_def, model, xi, zi)
% noiseparam0 = stk_param_init_lnv(ml_nv_def, model, xi, zi)
%
% Furnish a default value for a multi-level noise variance parameter of a model.
%
% - ml_nv_def : a default multi-level noise variance parameter, to select
% the good function, and  furnish the default levels;
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

%% Furnish a default inital value of the noise variance
model.lognoisevariance = ml_nv_def;
ml_nv0 = ml_nv_def;
nbLev = length(ml_nv_def.levels);

% We will work with the ratio eta = sigma2_noise / sigma2
log_eta_min = -15*ones(1, nbLev);  % exp(-15) = 3e-7 approx  -> very small noise
log_eta_max = +15*ones(1, nbLev);  % exp(+15) = 3e+7 approx  -> very large noise

bndLev = [log_eta_min;
    log_eta_max;];

if nbLev > 5
    nlogEta = 3^nbLev;
else %1 <= nbLev <= 4
    nlogEta = ( ceil(( 5*nbLev )^(1/nbLev)) )^nbLev;
end
log_eta_list = double( stk_sampling_regulargrid(nlogEta, nbLev, bndLev) );

%% Initialize parameter search
log_eta_best = nan*ones(1, nbLev);
aLL_best = +inf;

%% Find log-sigma2
covparam = model.param;
logsigma2 = stk_getLogSigma2(covparam);

%% Try all values from log_eta_list
for kle = 1:nlogEta
    log_eta = log_eta_list(kle, :);
    model.lognoisevariance(:) = logsigma2 + log_eta;
    aLL = stk_param_relik (model, xi, zi);
    if (~ isnan (aLL)) && (aLL < aLL_best)
        log_eta_best = log_eta;
        aLL_best    = aLL;
    end
end

%% If not any best value
if isinf (aLL_best)
    errmsg = 'Couldn''t find reasonable parameter values... ?!?';
    stk_error (errmsg, 'AlgorithmFailure');
end

%% Return the best value
ml_nv0.lognoisevar = logsigma2 + log_eta_best;

end

