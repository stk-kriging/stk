% STK_UPDATE...

function data = stk_update (data, x_new, z_new, z_new_var, z_new_nrep)

switch nargin
    
    case {0, 1}
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2
        % CALL: DATA = stk_update (DATA, X_NEW)
        z_new = [];
        z_new_var = [];
        z_new_nrep = [];
        
    case 3
        % CALL: DATA = stk_update (DATA, X_NEW, Z_NEW)
        z_new_var = [];
        z_new_nrep = [];
        
    case 4
        stk_error ('Incorrect number of input arguments', 'SyntaxError');
end

empty_x_new = isequal (x_new, []);
empty_z_new = isequal (z_new, []);

% Determine the sample size
if empty_x_new
    n_new = size (z_new, 1);
else
    n_new = size (x_new, 1);
    if ~ (empty_z_new || size (z_new, 1) == n_new)
        stk_error (['z must either be [] or have the same ' ...
            'number of rows as x.'], 'IncorrectSize');
    end
end

% Check input dimension
if size (x_new, 2) ~= data.input_dim
    stk_error (sprintf (['The number of colums of x (which is %d) ' ...
        'differs from input_dim=%d.'], size (x_new, 2), data.input_dim));
end

% Check output dimension
if size (z_new, 2) ~= data.output_dim
    stk_error (sprintf (['The number of colums of z (which is %d) ' ...
        'differs from output_dim=%d.'], size (z_new, 2), data.output_dim));
end

%%% SIMPLE SOLUTION: Merge first, find duplicates afterwards

if isequal (data.output_var, [])
    if ~ isequal (z_new_var, [])
        z_var = zeros (data.sample_size, data.output_dim);
        z_var = [z_var; z_new_var];
    else
        z_var = [];
    end
else
    if isequal (z_new_var, [])
        z_new_var = zeros (n_new, data.output_dim);
    end
    z_var = [data.output_var; z_new_var];
end

if isequal (data.output_nrep, [])
    if ~ isequal (z_new_nrep, [])
        z_nrep = ones (data.sample_size, 1);
        z_nrep = [z_nrep; z_new_nrep];
    else
        z_nrep = [];
    end
else
    if isequal (z_new_nrep, [])
        z_new_nrep = ones (n_new, 1);
    end
    z_nrep = [data.output_nrep; z_new_nrep];
end

sample_size = data.sample_size + n_new;
x = [data.input_data; x_new];
z = [data.output_data; z_new];

% Deal with repetitions
switch data.rep_mode
    
    case 'forbid'
        x_ = unique (x, 'rows');
        if size (x_, 1) < sample_size
            stk_error (['Found repeated rows while rep_mode ' ...
                'is set to ''forbid''.'], 'IncorrectArgument');
        end
        
    case 'gather'
        [x, z, z_var, z_nrep] = gather_repetitions_inside (x, z, z_var, z_nrep);
        sample_size = size (x, 1);
        
end % switch

% FIXME: Implement more efficient solution, where we leverage the fact that
%        the existing input data contains no duplicated rows (that is, if
%        repm_mode is either 'forbid' or 'gather')?

data.sample_size = sample_size;
data.input_data  = x;
data.output_data = z;
data.output_var  = z_var;
data.output_nrep = z_nrep;

end % function
