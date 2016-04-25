function [lb, ub] = stk_param_getdefaultbounds (covariance_type, covparam0, xi, zi)
% [lb, ub] = stk_param_getdefaultbounds (covariance_type, covparam0, xi, zi)
%
% Furnish default bounds for parameter estimation.
% lb <= param_opt(:) <= ub
%
% - covariance_type : must be 'stk_covariance' (old implementation);
% - model : the model where a parameter must be estimated;
% - (xi, zi) : the set of observation. xi : inputs; zi : outputs;

warning('STK:stk_param_getdefaultbounds:weakImplementation',...
    'You should implement a function ''stk_param_getdefaultbounds'' for your own class.');

% Check number of inputs
if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

%% Check covariance-type
if ~ischar(covariance_type)
    stk_error('The covariance must be a name.', 'InvalidArgument')
elseif strcmp(covariance_type, 'stk_covariance')
    stk_error('covariance_type must be ''stk_covariance''.', 'InvalidArgument')
end

% Furnish a default bounds for parameter covariance during an optimization... theoretically
covparamLb = covparam0;
covparamUb = covparam0;
stk_error(['You cannot use the default function ''stk_param_getdefaultbounds''.',...
    'Implement it for your own class.'], 'NoImplementation');
lb = vectorize_param(covparamLb);
ub = vectorize_param(covparamUb);
end

