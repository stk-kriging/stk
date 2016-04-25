function [name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(param)
% [name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(param)
%
% Return the list of fields which contains an optimizable data, id est,
% by default a double.
% The second output is the cumul sum of number of parameters for each fields.
% cumlength_optim_fields(1) = 0.
% total_lenght is the last value of cumlength_optim_fields.

warning('STK:get:weakImplementation',...
    'You should implement a function ''optimizable_fields'' for your own class.');

%% Set of every fields
fields = fieldnames(param);

index = [];         %set of index in fields which are optimizable.
cumlength_optim_fields = 0;

nbFields = 1;   % length(cumlength_optim_fields)
for kf = 1:length(fields)
    
    nameProperty = fields{kf, 1};
    property = get(param, nameProperty);
    if isnumeric(property)
        lenProp = length(property(:));
        lenCurr = cumlength_optim_fields(nbFields);
        
        index = cat(1, index, kf);
        cumlength_optim_fields = cat(1,...
            cumlength_optim_fields, lenCurr + lenProp);
        nbFields = nbFields + 1;
    end
        
end

name_optim_fields = fields(index);
total_lenght = cumlength_optim_fields(nbFields);
end

