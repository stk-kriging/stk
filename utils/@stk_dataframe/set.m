function x = set (x, propname, value)

icol = get_column_number (x.vnames, propname);

switch icol
    
    case -3 % 'rownames'
        x.rownames = value;
        
    case -2 % 'colnames'
        x.vnames = value;
            
    case - 1 % set entire array
        if isequal (size(x.data), size(value))
            x.data = value;
        else
            error ('Incorrect size');
        end
        
    otherwise
        if isequal (size(value), [size(x.data, 1) 1])
            x.data(:, icol) = value;
        else
            error ('Incorrect size');
        end
        
end

end % function get
