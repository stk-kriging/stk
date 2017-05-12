function value = get (cstnoisevar, propname)
% value = get (cstnoisevar, propname)
%
% Get the value of constant noise variance parameter properties.

switch propname
    case 'lognoisevar'
        value = cstnoisevar.lognoisevar;
    otherwise
        stk_error(['The constant noise variance parameter', ...
            ' does not have any property whose name is ',...
            propname, '.'], 'InvalidArgument')
end

end

