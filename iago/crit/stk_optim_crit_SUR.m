% STK_OPTIM_CRIT_SUR SUR criteria
%
% CALL: stk_optim_crit_SUR()
%
% STK_OPTIM_CRIT_SUR chooses evaluation point using SUR criteria

% Copyright Notice
%
%    Copyright (C) 2015, 2016, 2020 CentraleSupelec
%
%    Author:  Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>
%             Julien Bect       <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function [zp, samplingcrit] = stk_optim_crit_SUR (algo, xi_ind, zi, type)

error ('This function needs a big rehaul (see stk_optim_crit_iago).');

if nargin < 4
    type = 1;
end

% Make sure that lognoisevariance is -inf for noiseless models
if ~ stk_isnoisy (algo.model)
    algo.model.lognoisevariance = -inf;
end

xg = algo.xg0;
ng = stk_get_sample_size (xg);
xi = xg(xi_ind, :);
ni = stk_get_sample_size (xi);

%% INITIAL PREDICTION
% zp = stk_predict (algo.model, xi_ind, zi, xg);
model_xg = stk_model (@stk_discretecov, algo.model, xg);
[model_xg, zi] = stk_fakenorep (model_xg, zi);
zp = stk_predict(model_xg, xi_ind, zi, []);
zpmean = zp.mean;
zpvar  = zp.var;

%% ACTIVATE DISPLAY?
if algo.disp; view_init(algo, xi, zi, xg); end

%% COMPUTE THE STEPWISE UNCERTAINTY REDUCTION CRITERION

% allocate sampling criterion vector
samplingcrit = zeros(ng, 1);

% Heteroscedastic noise ?
heteroscedastic_noise = ~ isscalar (algo.noisevariance);

% Prepare future noise variance
if isinf (algo.futurebatchsize),
    % Pretend that the future observation will be noiseless
    heteroscedastic_noise = false;
    noisevariance = 0;
    lnv = - inf;
elseif ~ heteroscedastic_noise
    noisevariance = algo.noisevariance / algo.futurebatchsize;
    lnv = log (noisevariance);
end

for test_ind = 1:ng
    
    xi_ind(ni+1) = test_ind;
    xi = xg(xi_ind, :);
    
    % Noise variance
    if heteroscedastic_noise
        noisevariance = algo.noisevariance(test_ind) / algo.futurebatchsize;
        lnv = log (noisevariance);
    end
    
    % Heteroscedastic case: store lnv in model.lognoisevariance
    % (because we called stk_fakenorep, model_.lognoisevariance is a vector)
    model_ = model_xg;
    model_.lognoisevariance = [model_.lognoisevariance; lnv];
        
    if size(xi.data, 1) == size(unique(xi.data, 'rows'), 1) || noisevariance > 0.0
        
        % [zpcond, lambda] = stk_predict(algo.model, xi, [], xg);
        [zpcond, lambda] = stk_predict(model_, xi_ind, [], []);
        zQ = stk_quadrature(1, algo, zpmean(test_ind), abs(zpvar(test_ind)) + noisevariance);
        losscrit = zeros(algo.quadorder,1);
        for k = 1:algo.quadorder
            zi_ =  [zi.data; zQ(k)]; % add a fictitious observation
            zpm = lambda' * zi_;
            losscrit(k) = stk_losscrit(type, zi_, zpm, zpcond.var);
        end
        samplingcrit(test_ind) = stk_quadrature(2, algo, losscrit);
        
    else
        
        xi_ind = xi_ind(1:ni); % drop the test point
        samplingcrit(test_ind) = stk_losscrit(type, zi, zpmean, zpvar);
        
    end
end

%% DISPLAY SAMPLING CRITERION?
if algo.disp,
    [~, ind_min] = min(samplingcrit);  xinew = xg(ind_min, :); %%%TEMP
    view_samplingcrit(algo, xg, xi, xinew, samplingcrit, 2);
end

end %%END stk_optim_crit_SUR
