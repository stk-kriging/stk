function s = stk_hrect (arg1, colnames)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if isa (arg1, 'stk_hrect')  % arg1 is already an stk_hrect object: copy
    
    s = arg1;
    
else  % create a new stk_hrect object
    
    if isscalar (arg1)  % arg1 is the dimension of the input space
        % => create a default hyper-rectangle [0; 1]^d, with d = arg1
        d = arg1;
        box_data = repmat ([0; 1], 1, d);
    else
        box_data = double (arg1);
        d = size (box_data, 2);
        if (~ isequal (size (box_data), [2 d]))
            stk_error ('Invalid size: should be 2 x dim.', 'IncorrectSize');
        end
    end
        
    if (~ all (box_data(1, :) <= box_data(2, :)))
        stk_error ('Invalid bounds', 'InvalidBounds');
    end
    
    df = stk_dataframe (box_data, {}, {'lower_bounds', 'upper_bounds'});
    s = class (struct (), 'stk_hrect', df);
    
end

% column names
if nargin > 1,
    s.stk_dataframe.colnames = colnames;
end

end % function stk_hrect
