function noiseparam = stk_noisevar_param(varargin)
% lnvparam = stk_noisevar_param(varargin)
%
% An abstract constructor for an abstract classe noise variance parameters.

noiseparam = struct();
noiseparam = class(noiseparam, 'stk_noisevar_param', stk_param());
end