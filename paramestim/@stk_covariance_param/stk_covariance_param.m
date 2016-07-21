function covparam = stk_covariance_param(varargin)
% covparam = stk_covariance_param(varargin)
%
% An abstract constructor for an abstract classe covariance parameters.

covparam = struct();
covparam = class(covparam, 'stk_covariance_param', stk_param());
end

