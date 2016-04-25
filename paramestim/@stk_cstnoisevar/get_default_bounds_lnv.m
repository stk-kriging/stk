function [lblnv, ublnv] = get_default_bounds_lnv(model, cstnoisevar0, xi, zi)
% [lblnv, ublnv] = get_default_bounds_lnv(model, lnv0, xi, zi)
%
% Provide default bounds optimization for lnv0.

TOLVAR = 0.5;

% Bounds for the variance parameter
empirical_variance = var(zi);
lblnv = log (eps);
ublnv = log (empirical_variance) + TOLVAR;

% Make sure that lnv0 falls within the bounds
if ~ isempty (cstnoisevar0)
    lblnv = min (lblnv, cstnoisevar0.lognoisevar - TOLVAR);
    ublnv = max (ublnv, cstnoisevar0.lognoisevar + TOLVAR);
end

