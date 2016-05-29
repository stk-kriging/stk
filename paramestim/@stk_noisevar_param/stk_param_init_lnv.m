function noiseparam0 = stk_param_init_lnv(noiseparam_def, model, xi, zi)
% noiseparam0 = stk_param_init_lnv(noiseparam_def, model, xi, zi)
%
% Furnish a default value for a noise parameter of a model.
%
% - noiseparam_def : a default noise variance parameter, to select
% the good function, and furnish some defaut values;
% - model : the model where a parameter must be estimated;
% - (xi, zi) : the set of observation. xi : inputs; zi : outputs;

warning('STK:stk_param_init_lnv:weakImplementation',...
    'You should implement a function ''stk_param_init_lnv'' for your own class.');

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

%% Furnish a default inital value of the noise variance... theoretically
noiseparam0 = noiseparam_def;
stk_error(['You cannot use the default function ''stk_param_init_lnv''.',...
    'Implement it for your own class.'], 'NoImplementation');

end

