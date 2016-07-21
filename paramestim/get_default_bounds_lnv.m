function [lblnv,ublnv] = get_default_bounds_lnv (model, lnv0, xi, zi)
% [lblnv,ublnv] = get_default_bounds_lnv (model, lnv0, xi, zi)
%
% Define default bounds for log-noise variance, when the noise is
% homo-scedastic, and must be estimated.

TOLVAR = 0.5;

% Bounds for the variance parameter
empirical_variance = var(zi);
lblnv = log (eps);
ublnv = log (empirical_variance) + TOLVAR;

% Make sure that lnv0 falls within the bounds
if ~ isempty (lnv0)
    lblnv = min (lblnv, lnv0 - TOLVAR);
    ublnv = max (ublnv, lnv0 + TOLVAR);
end

end % function