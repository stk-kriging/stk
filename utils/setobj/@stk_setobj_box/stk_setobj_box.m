function s = stk_setobj_box (varargin)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin == 1,
    
    if isa (varargin{1}, 'stk_setobj_box')
        
        s = varargin{1};
        return;
        
    elseif isscalar (varargin{1})
        
        % default: [0; 1]^d
        d = varargin{1};        
        lb = zeros (1, d);
        ub = ones (1, d);
        
    else
        
        % otherwise, assume a 2 x d matrix
        box = varargin{1};
        d = size (box, 2);
        assert (isequal (size (box), [2 d]));
        lb = box(1, :);
        ub = box(2, :);
        
    end
    
else % nargin == 2
    
    lb = varargin{1};
    if iscolumn (lb),  % accept both row and column vector arguments
        lb = lb';
    end
    
    ub = varargin{2};
    if iscolumn (ub),  % idem
        ub = ub';
    end
        
    d  = size (lb, 2);
    assert (isequal (size (lb), [1 d]));
    assert (isequal (size (ub), [1 d]));
    
end

assert (all (lb <= ub));
s = struct ('lb', lb, 'ub', ub);
s = class (s, 'stk_setobj_box');

end % function stk_setobj_box
