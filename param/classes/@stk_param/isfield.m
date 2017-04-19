function isFieldExist = isfield(param, propname)
% isFieldExist = isfield(param, propname)
%
% Check if a field exists.

isFieldExist = isfield(struct(param), propname);

end

