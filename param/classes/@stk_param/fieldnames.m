function fields = fieldnames(param)
% fields = fieldnames(param)
%
% Return the fields of parameters.

warning('STK:fieldnames:weakImplementation',...
    'You should implement a function ''fieldnames'' for your own class.');

persistent type0 fields0

if isempty(type0) || isa(param, type0) == false
    currentFields = fieldnames(struct(param));
    currentFields = currentFields(~strcmp(currentFields, 'stk_param'));
    fields0 = currentFields;
    type0 = class(param);
end

fields = fields0;
end

