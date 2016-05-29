function [covparam0, noiseparam0] = stk_param_init(covparam_def, model, xi, zi, box, do_estim_noiseparam)
% covparam0 = stk_param_init(covparam_def, model, xi, zi, box)
% [covparam0, noiseparam0] = stk_param_init(covparam_def, model, xi, zi, box, do_estim_lnv)
%
% Furnish a default value for the covariance parameter, and a noise
% variance parameter.
%
% - covparam_def : a default parameter, to select the good function, and
% furnish some defaut values;
% - model : the model where a parameter must be estimated;
% - (xi, zi) : the set of observation. xi : inputs; zi : outputs;
% - box : define the hyper-square of posible values of xi. Default vlaue :
% box = [min(xi); max(xi)];
% - do_estim_noiseparam :  (default value : any(isnan(model.lognoisevariance))
% a boolean indicating if the noise parameter must be initializate or not;

warning('STK:stk_param_init:weakImplementation',...
    'You should implement a function ''stk_param_init'' for your own class.');

% Check number of inputs
if nargin > 6,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

%% Check size
if size(zi, 1) ~= size(xi, 1)
    stk_error('zi should have the same number of rows as xi.', 'IncorrectSize');
end
if size(zi, 2) ~= 1
    stk_error ('zi should be a column.', 'IncorrectSize');
end

%% Box value
if nargin < 5,
    box = [];
end

if ~ isa (box, 'stk_hrect')
    if isempty (box),
        box = stk_boundingbox (xi);  % Default: bounding box
    else
        box = stk_hrect (box);
    end
end

%% noisy

% Backward compatiblity: accept model structures with missing lognoisevariance
if (~ isfield (model, 'lognoisevariance')) || (isempty (model.lognoisevariance))
    model.lognoisevariance = stk_cstnoisevar(-inf);
end

noiseparam_def = model.lognoisevariance;
if nargin < 6 || isempty(do_estim_noiseparam)
    do_estim_noiseparam = any( isnan(noiseparam_def(:)) );
end

if isnumeric(noiseparam_def)
    if isscalar(noiseparam_def)    %case : lnv is an unique scalar parameter
        % ==> use the class stk_cstnoisevar
        noiseparam_def = stk_cstnoisevar(noiseparam_def);
        model.lognoisevariance = noiseparam_def;
        [covparam0, noiseparam0] = ...
            stk_param_init(covparam_def, model, xi, zi, box, do_estim_noiseparam);
        return;
        
    else %case : lnv is a vector of noise variance
        if any (isnan (noiseparam_def))% Noise variance estimation is not supported in the heteroscedastic case
            stk_error (['model.lognoisevariance is non-scalar and contains nans. ' ...
                'Noise variance estimation is not supported in the heteroscedastic ' ...
                'case '], 'InvalidArgument');
        end
        
        if do_estim_noiseparam
            stk_error (['Noise variance estimation is not supported in the ' ...
                'heteroscedastic case '], 'InvalidArgument');
        end
        
    end
    
else %if lnv is a class
    if do_estim_noiseparam
        noiseparam_def(:) = nan;
    elseif any(isnan (noiseparam_def(:)))
        stk_error (sprintf ...
            (['do_estim_noiseparam is false, but model.lognoisevariance ' ...
            'has nan value(s). If you don''t want the noise variance to be ' ...
            'estimated, you must provide a value for it!']), ...
            'MissingParameterValue');
    end
end

% Incompatible input-output
if (do_estim_noiseparam) && (nargout < 2)
    warning (['stk_param_init will be computing an estimation of the ' ...
        'variance of the noise, perhaps should you call the function ' ...
        'with two output arguments?']);
end

model.lognoisevariance = noiseparam_def;

%% linear model

% We currently accept both model.order and model.lm
if isfield (model, 'lm')
    if ~ isnan (model.order)
        stk_error (['Invalid ''model'' argument: model.order should be' ...
            'set to NaN when model.lm is present.'], 'InvalidArgument');
    end
else
    model.lm = stk_lm_polynomial (model.order);
end

% Furnish a default inital value of the covariance parameter... theoretically
covparam0 = covparam_def;
stk_error(['You cannot use the default function ''stk_param_init''.',...
    'Implement it for your own class.'], 'NoImplementation');
if do_estim_noiseparam
    model.param = covparam0;
    noiseparam0 = stk_param_init_lnv(model.lognoisevariance, model, xi, zi);
end

end