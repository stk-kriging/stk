function param = subsasgn(param, idx, val)
% param = subsasgn(param, idx, val)
%
% Allow to modify parameter properties with operators.

switch idx(1).type
    case '.'
        if length(idx) == 1
            param = set (param, idx(1).subs, val);
        else
            obj = get(param, idx(1).subs);
            obj = subsasgn(obj, idx(2:length(idx)), val);
            param = set(param, idx(1).subs, obj);
        end
        
    case '()'
        vector = vectorize_param(param);
        vector(idx(1).subs{1}) = val;
        param = modify_param(vector, param);
        
    otherwise
        error(['Sorry, but the program does not understand the operator ', ...
            idx(1).type, ' for stk_param.'])
end

end

