function [name_fields_diff, numb_diff] = findFieldToDifferentiate(diff, param)
% [name_fields_diff, numb_diff] = findFieldToDifferentiate(diff, param)
%
% This function should be used when derivative with respect to a parameter
% want to be caculated. This function takes an integer "diff" and a
% parameter, and return the field which must be derivative, and the
% number inside the field which must be derivative.
%
% - diff : an integer between 1 and length(param(:))
% - param : an stk_parameter
%
% * name_fields_diff : the field name of param which must be derivate
% * numb_diff : an integer between 1 and length( get(param,
% name_fields_diff) ), indicating which number inside the field must be
% derivate.
%
% Ex : dim = 4; param = stk_materncoviso_param(dim);
%   
%   param = 
% 
% logsig2 : NaN
%  logreg : NaN
%  logacc : NaN
%           NaN
%           NaN
%           NaN
%
%   findFieldToDifferentiate(1, param) ==> [logsig2, 1]
%   findFieldToDifferentiate(2, param) ==> [logreg, 1]
%   findFieldToDifferentiate(3, param) ==> [logacc, 1]
%   findFieldToDifferentiate(4, param) ==> [logacc, 2]
%   findFieldToDifferentiate(5, param) ==> [logacc, 3]
%   findFieldToDifferentiate(6, param) ==> [logacc, 4]
%   findFieldToDifferentiate(7, param) ==> Error : the diff parameter must
%   be a positive number lower than the number of parameters (here 6).

if diff < 1
    stk_error('The ''diff'' parameter must be a positive non-zero integer.',...
        'InvalidArgument');
end

[name_optim_fields, cumlength_optim_fields, total_lenght] = optimizable_fields(param);

if diff > total_lenght
    stk_error(['The ''diff'' parameter must be a positive non-zero integer,',...
        'lower than the total number of parameters (here ',...
        num2str(total_lenght),').'], 'InvalidArgument');
end

ind_diff = find(diff <= cumlength_optim_fields, 1);

name_fields_diff = name_optim_fields{ind_diff - 1};
numb_diff = diff - cumlength_optim_fields(ind_diff - 1);
end

