function [lblnv, ublnv] = get_default_bounds_lnv(model, lnv0, xi, zi)
% [lblnv, ublnv] = get_default_bounds_lnv(model, lnv0, xi, zi)
%
% Provide default bounds optimization for lnv0.

warning('STK:get_default_bounds_lnv:weakImplementation',...
    'You should implement a function ''get_default_bounds_lnv'' for your own class.');

%%
stk_error(['You cannot use the default function ''get_default_bounds_lnv''.',...
    'Implement it for your own class.'], 'NoImplementation');
end

