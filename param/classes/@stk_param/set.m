function param = set(param, propname, value)
% param = set(param, propname, value)
%
% Change parameter properties.

%
warning('STK:set:weakImplementation',...
    'You should implement a function ''set'' for your own class.');

%
oldValue = get(param, propname);


% Compare classes
class_old = class(oldValue);
class_new = class(value);
if ~strcmp(class_old, class_new)
    stk_error(['The willing new value should be a ', class_old,...
        ', but it is a ', class_new, '.'], 'InvalidArgument');
end

% Delete blank
if ischar(value)
    value = char(cellstr(value));
end

% Resize new value
if isnumeric(value) || isa(value, 'stk_dataframe')...
        || islogical(value) || iscell(value)
    value = stk_checkSize(oldValue, value);
end

% Change value... theoretically
stk_error(['You cannot use the default function ''set''.',...
    'Implement it for your own class.'], 'NoImplementation');
end

