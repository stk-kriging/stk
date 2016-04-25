function in = isnoisy( noiseparam )
% in = isnoisy( noiseparam )
%
% Indicate if there is noise, or not.

% Backward compatibility : noiseparam is a vector of noise variance.

in = any(~isinf(noiseparam)) || any(noiseparam > 0);
%true, if there is at least 1 lnv ~= -Inf
end

