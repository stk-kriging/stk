function b = stk_is_lhs(x, n, dim, box)

if nargin < 4,
    box = [zeros(1, dim); ones(1, dim)];
end

xmin = box(1, :);
xmax = box(2, :);

for j = 1:dim,
    
    y = x.a(:,j);
    
    if (xmin(j) > min(y)) || (xmax(j) < max(y))
        b = false; return;
    end
    
    y = (y - xmin(j)) / (xmax(j) - xmin(j));
    y = ceil(y * n);
    if ~isequal(sort(y), (1:n)'),
        b = false; return;
    end
    
end

b = true;

end