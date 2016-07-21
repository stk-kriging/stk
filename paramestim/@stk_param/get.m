function value = get (param, propname)
% value = get (param, propname)
%
% Get the value of parameter properties.

warning('STK:get:weakImplementation',...
    'You should implement a function ''get'' for your own class.');

s = struct (param);
value = s.(propname);
end

