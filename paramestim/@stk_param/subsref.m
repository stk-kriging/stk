function info = subsref (param, idx)
% info = subsref (param, idx)
%
% Allow to access of parameters properties with '.' and '()'

switch idx(1).type
    case '.'
        info = get (param, idx(1).subs);
        
    case '()'
        param = stk_get_optimizable_parameters (param);
        info = param(idx(1).subs{1});
        
    otherwise
        error(['Sorry, but the program does not understand the operator ', ...
            idx(1).type, ' for stk_param.'])
end

if (length (idx)) > 1,
    info = subsref (info, idx(2:end));
end

end

