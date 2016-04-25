function in = isnoisy( cstnoisevar )
% in = isnoisy( cstnoisevar )
%
% Indicate if there is noise, or not.

lnv = cstnoisevar.lognoisevar;
in = (~isinf(lnv) || lnv > 0);  % lnv ~= -Inf
end