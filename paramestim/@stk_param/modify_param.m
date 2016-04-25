function param = modify_param(vector, param)
% param = modify_param(vector, param)
%
% Used by subsagn, this functions allows to build different parameters from
% a vector.

[name_fields, cumlength_fields, total_lenght] = optimizable_fields(param);

if total_lenght ~= length(vector)
    stk_error(['The length of new parameter vector (', num2str(length(vector)),...
    ') does not match the number of parameters (', num2str(total_lenght),').'],...
    'InvalidArgument');
end

for kf = 1:length(name_fields)
    param = set(param, name_fields{kf, 1},...
        vector( (cumlength_fields(kf) + 1):(cumlength_fields(kf + 1)) ) );
end

end