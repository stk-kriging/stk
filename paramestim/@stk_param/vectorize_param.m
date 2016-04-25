function vector_param = vectorize_param( param )
% vector_param = vectorize_param( param )
%
% Return the complete vector of parameters which must be optimized


[name_fields, cumlength_fields, total_lenght] = optimizable_fields(param);

vector_param = zeros(total_lenght, 1);
for ko = 1:length(name_fields)
    property = get(param, name_fields{ko, 1});
    
    vector_param( (cumlength_fields(ko) + 1):(cumlength_fields(ko + 1)) ) = property(:);
end

end

