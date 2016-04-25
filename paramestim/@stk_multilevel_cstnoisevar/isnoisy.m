function in = isnoisy( ml_nv )
% in = isnoisy( ml_nv )
%
% Indicate if there is noise, or not.

lnv = ml_nv.lognoisevar;
in = any(~isinf(lnv)) || any(lnv > 0);  %there is at least 1 lnv ~= -Inf
end