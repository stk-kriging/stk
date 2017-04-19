function cstnoisevar = set(cstnoisevar, propname, value)
% cstnoisevar = set(cstnoisevar, propname, value)
%
% Change constant noise variance parameter properties.

switch propname
    case 'lognoisevar'
        value = double(value);
        
        if ~isscalar(value)
            stk_error('A new value of a log-noise variance must be a scalar.', 'InvalidArgument');
        end
        cstnoisevar.lognoisevar = value;
        
    otherwise
        stk_error(['The nested design has not any property whose name is ',...
            propname, '.'], 'InvalidArgument')
end
end

