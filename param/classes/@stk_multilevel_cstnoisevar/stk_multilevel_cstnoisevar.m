function ml_nv = stk_multilevel_cstnoisevar(values, levels)
% ml_nv = stk_multilevel_cstnoisevar(values, levels)
%
% Create an object multi-level noise variance to model
% multi-level noises.

if nargin > 2
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

%% Default constructor
if nargin == 0
    values = NaN*ones(1, 2);
    levels = [1, 0];
    
elseif nargin == 1
    %if values is provided
    values = double(values(:)');    % row vector
    levels = 1:( (0 - 1)/(length(values) - 1) ):0;
else % nargin == 2
    %if levels is provided
    levels = double(levels(:)');    % row vector
    
    if isempty(values)
        values = NaN*ones(1, length(levels));
    else
        values = double(values(:)');
        if length(values) ~= length(levels)
            stk_error('Values and levels must have the same size.', 'InvaliArgument');
        end
    end
end

ml_nv = struct ('lognoisevar', values, 'levels', levels);
ml_nv = class (ml_nv, 'stk_multilevel_cstnoisevar', stk_noisevar_param());
end