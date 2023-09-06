% STK_IODATA...
%
% Note: inputs ASSUMED (not checked) unique if rep info is provided
%

function data = stk_iodata (x, z, varargin)

% FIXME: Deal with other types of inputs: stk_dataframe and/or table !!!

if nargin == 0  % Special case: default constructor
    x = [];
    z = [];
end

p = inputParser ();

% Except in the defaut constructor case, those two are mandatory:
addRequired (p, 'x');
addRequired (p, 'z');

% Then we have these two, that should be either both present or both absent:
addOptional (p, 'z_var',  []);
addOptional (p, 'z_nrep', []);

% Valid rep_mode values
valid_rep_mode = @(s) ismember (s, {'ignore', 'forbid', 'gather'});

% Name-value pairs:
addParameter (p, 'input_dim',  []);
addParameter (p, 'output_dim', []);
addParameter (p, 'rep_mode', 'ignore', valid_rep_mode);

parse (p, x, z, varargin{:});

empty_x = isequal (x, []);
empty_z = isequal (z, []);

% Determine the sample size
if empty_x
    sample_size = size (z, 1);
else
    sample_size = size (x, 1);
    if ~ (empty_z || size (z, 1) == sample_size)
        stk_error (['zi must be [] or have the same ' ...
            'number of rows as xi.'], 'IncorrectSize');
    end
end

% Determine input_dim
input_dim = p.Results.input_dim;
if empty_x
    if isempty (input_dim)
        input_dim = 0;
    else
        x = zeros (sample_size, input_dim);
    end
else
    sx = size (x);
    if length (sx) > 3
        stk_error ('x must be a matrix-like array', 'IncorrectSize');
    end
    if isempty (input_dim)
        input_dim = sx(2);
    else
        if input_dim ~= sx(2)
            stk_error (['The number of columns of x should match ' ...
                'the value of the input_dim parameter.']);
        end
    end
end

% Determine output_dim
output_dim = p.Results.output_dim;
if empty_z
    if isempty (output_dim)
        output_dim = 0;
    end
    z = zeros (sample_size, output_dim);
else
    sz = size (z);
    if length (sz) > 3
        stk_error ('z must be a 2d array', 'IncorrectSize');
    end
    if isempty (output_dim)
        output_dim = sz(2);
    else
        if output_dim ~= sz(2)
            stk_error (['The number of columns of z should match ' ...
                'the value of the `output_dim` parameter.']);
        end
    end
end

% Check z_var
z_var = p.Results.z_var;
if ~ isequal (z_var, [])
    if ~ isequal (size (z_var), [sample_size output_dim])
        stk_error (sprintf (['z_var should be a 2d array with ' ...
            'sample_size=%d rows and output_dim=%d columns.'], ...
            sample_size, output_dim));
    end
    if any (z_var < 0)
        stk_error ('z_var has negative entries', 'IncorrectArgument');
    end
end

% Check z_nrep
z_nrep = p.Results.z_nrep;
z_nrep_provided = ~ isequal (z_nrep, []);
if z_nrep_provided
    if ~ isequal (size (z_nrep), [sample_size 1])
        stk_error (sprintf (['z_nrep should be a column vector ' ...
            'sample_size=%d rows'], sample_size));
    end
    if any (z_nrep < 0)
        stk_error ('z_nrep has negative entries', 'IncorrectArgument');
    end
end

% Deal with repetitions
switch p.Results.rep_mode
          
    case 'forbid'
        if z_nrep_provided
            assert (all (z_nrep == 0) && all (z_var == 0));
            z_nrep = [];
            z_var = [];
        else
            x_ = unique (x, 'rows');
            if size (x_, 1) < sample_size
                stk_error (['Found repeated rows in x while rep_mode ' ...
                    'is set to ''forbid''.'], 'IncorrectArgument');
            end
        end
        
    case 'gather'
        [x, z, z_var, z_nrep] = gather_repetitions_inside (x, z, z_var, z_nrep);
        sample_size = size (x, 1);
        
end % switch

data.sample_size = sample_size;
data.input_dim   = input_dim;
data.input_data  = x;
data.output_dim  = output_dim;
data.output_data = z;
data.output_var  = z_var;
data.output_nrep = z_nrep;
data.rep_mode    = p.Results.rep_mode;

data = class (data, 'stk_iodata');

end % function

