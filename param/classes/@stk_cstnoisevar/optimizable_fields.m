function [name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(cstnoisevar)
% [name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(cstnoisevar)
%
% Return the list of fields which contains an optimizable data : {'lognoisevar'}
% The second output is the cumul sum of number of parameters for each fields.
% cumlength_optim_fields = [0; 1].
% total_lenght is the last value of cumlength_optim_fields : 1.

name_optim_fields = {'lognoisevar'};
cumlength_optim_fields = [0; 1];
total_lenght = 1;
end

