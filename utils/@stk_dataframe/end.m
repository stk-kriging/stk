function idx = end(x, k, nb_indices)

if nb_indices == 2,
    
    % using two indices
    idx = size(x.data, k);
    
elseif nb_indices == 1,
    
    % using linear indexing
    idx = numel(x.data);
    
else
    
    errmsg = 'stk_dataframe objects only support linear or matrix-type indexing.';
    stk_error(errmsg, 'IllegalIndexing');

end % if

end % function


%!shared x
%! x = stk_dataframe([1 2; 3 4; 5 6]);
%!assert (isequal (x(2:end, :), x(2:3, :)))
%!assert (isequal (x(2, 1:end), x(2, :)))
%!assert (isequal (x(2:end, 2:end), x(2:3, 2)))
%!assert (isequal (x(1:end), x(1:6)))
