function [xg, xi_ind, algo] = stk_searchgrid(algo, xi)

%if algo.searchgrid_adapt;
%    algo = stk_move_the_xg0(algo, xg, xi, xi_ind, zi); end

ni = stk_length(xi);
if algo.searchgrid_unique
    [xg, ixixg, ixg] = unique([xi.data; algo.xg0.data], 'rows');
    xg = stk_dataframe(xg);
    xi_ind = ixg(1:ni);
    if ~strcmp(algo.noise, 'noisefree')
        noisevariance = [xi.noisevariance; algo.xg0.noisevariance];
        noisevariance = noisevariance(ixixg);
        xg = stk_ndf(xg, noisevariance);
    end
else
    xg = [xi; algo.xg0];
    xi_ind = 1:ni;
end

