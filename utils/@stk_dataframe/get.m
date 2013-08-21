function value = get (x, propname)

icol = get_column_number (x.vnames, propname);

switch icol
    
    case -3 % 'rownames'
        value = x.rownames;
        
    case -2 % 'colnames'
        value = x.vnames;
            
    case -1 % get entire array
        value = x.data;
        
    otherwise
        value = x.data(:, icol);

end

end % function get
