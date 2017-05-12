function [lblnv, ublnv] = get_default_bounds_lnv(model, ml_nv0, xi, zi)
% [lblnv, ublnv] = get_default_bounds_lnv(model, lnv0, xi, zi)
%
% Provide default bounds optimization for lnv0.

%% Check size
xi = double(xi);
zi = double(zi);

dim = model.dim;

if size(xi, 2) ~= dim
    stk_error('xi and model have incompatible dimensions.', 'IncorrectSize')
end
if size(zi, 2) ~= 1
    stk_error('zi is not a vector', 'IncorrectSize')
end
if size(zi, 1) ~= size(xi, 1)
    stk_error('zi and xi have not the same lenght.', 'IncorrectSize');
end

%% Levels
xi_level = xi(:, dim);
levels = ml_nv0.levels;
nbLev = length(levels);

x_check = 0;    %check if levels of x are included in ml_nv0.levels
tolEps = 1e-5*range(levels);
for kl = 1:nbLev
    ind = abs(xi_level - levels(kl)) < tolEps;
    x_check = x_check + sum(ind);
end
if x_check ~= length(xi_level)
    stk_error('xi has incompatible levels with the stk_multilevel_cstnoisevar.',...
        'InvalidArgument')
end

ml_nvLb = ml_nv0;
ml_nvUb = ml_nv0;

%% Log-noisevariance
TOLVAR = 0.5;

for kl = 1:nbLev
    indKl = abs(xi_level - levels(kl)) < tolEps;
    xi_levelkl = xi_level(indKl, :);
    if ~isempty(xi_levelkl)
        zi_kl = zi(indKl, :);
        % Bounds for the variance parameter
        empirical_variance_kl = var(zi_kl);
        ml_nvLb.lognoisevar(kl) = log (eps);
        ml_nvUb.lognoisevar(kl) = log (empirical_variance_kl) + TOLVAR;
    else
        ml_nvLb.lognoisevar(kl) = log (eps);
        ml_nvUb.lognoisevar(kl) = ml_nv0.lognoisevar(kl) + 0.5;
    end
    
    % Make sure that lnv0 falls within the bounds
    if ~ isempty (ml_nv0)
        lnv0_kl = ml_nv0.lognoisevar(kl);
        ml_nvLb.lognoisevar(kl) = min(ml_nvLb.lognoisevar(kl), lnv0_kl - TOLVAR);
        ml_nvUb.lognoisevar(kl) = max(ml_nvUb.lognoisevar(kl), lnv0_kl + TOLVAR);
    end
end

% Transform the hyper-rectangle on hyper-square
ml_nvLb.lognoisevar = min(ml_nvLb.lognoisevar)*ones(1, nbLev);
ml_nvUb.lognoisevar = max(ml_nvUb.lognoisevar)*ones(1, nbLev);

%% Return vector
lblnv = stk_get_optimizable_parameters (ml_nvLb);
ublnv = stk_get_optimizable_parameters (ml_nvUb);

end

