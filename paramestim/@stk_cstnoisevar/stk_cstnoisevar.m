function cstnoisevar = stk_cstnoisevar(value)
% cstnoisevar = stk_cstnoisevar(value)
%
% Create an object constant noise variance to model homoscedastic noise.

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin == 0 || isempty(value)
    value = NaN;
end

if ~isscalar(value)
    stk_error('Value must be a single number', 'InvalidArgument');
end

cstnoisevar = struct ('lognoisevar', double(value));
cstnoisevar = class (cstnoisevar, 'stk_cstnoisevar', stk_noisevar_param());
end

