function value = get (ml_nv, propname)
% value = get (ml_nv, propname)
%
% Get the value of multi-level noise variance parameter properties.

switch propname
    case 'lognoisevar'
        value = ml_nv.lognoisevar;
    case 'levels'
        value = ml_nv.levels;
    otherwise
        stk_error(['The multi-level noise variance parameter', ...
            ' does not have any property whose name is ',...
            propname, '.'], 'InvalidArgument')
end

end

