function [name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(ml_nv)
% [name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(ml_nv)
%
% Return the list of fields which contains an optimizable data : {'lognoisevar'}
% The second output is the cumul sum of number of parameters for each fields.
% cumlength_optim_fields = [0; 1].
% total_lenght is the last value of cumlength_optim_fields : 1.

name_optim_fields = {'lognoisevar'};

nbLev = length(ml_nv.lognoisevar);

cumlength_optim_fields = [0; nbLev];
total_lenght = nbLev;
end

