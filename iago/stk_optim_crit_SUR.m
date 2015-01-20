% STK_OPTIM_CRIT_SUR SUR criteria
%
% CALL: stk_optim_crit_SUR()
%
% STK_OPTIM_CRIT_SUR chooses evaluation point using SUR criteria

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Author:   Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
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

function [xinew, xg, zp, algo, samplingcrit] = stk_optim_crit_SUR (algo, xi, zi, type)

if nargin < 4
    type = 1;
end

%% ESTIMATE MODEL PARAMETERS
if algo.estimparams
    fprintf('parameter estimation ..');
    if algo.estimnoise
        [algo.model.param, algo.model.lognoisevariance] = stk_param_estim (...
            algo.model, xi, zi, algo.model.param, algo.model.lognoisevariance);
        xi = stk_setnoisevariance(xi, exp(algo.model.lognoisevariance));
    else
        algo.model.param = stk_param_estim (algo.model, xi, zi, algo.model.param);
    end
    fprintf('done\n');
end

%% SEARCH GRID
[xg, xi_ind, algo] = stk_searchgrid(algo, xi);
ng = stk_length(xg);

%% INITIAL PREDICTION
% zp = stk_predict(algo.model, xi_ind, zi, xg);
model_xg = stk_model('stk_discretecov', algo.model, xg);
zp = stk_predict(model_xg, xi_ind, zi, []);
zpmean = zp.mean;
zpvar  = zp.var;
noisevariance = exp(algo.model.lognoisevariance);

%% ACTIVATE DISPLAY?
if algo.disp; view_init(algo, xi, zi, xg); end

%% COMPUTE THE STEPWISE UNCERTAINTY REDUCTION CRITERION

% allocate sampling criterion vector
samplingcrit = zeros(ng, 1);

for test_ind = 1:ng
    if algo.showprogress, progress_disp('    test point', test_ind, ng); end
    xi_ind(ni+1) = test_ind;
    xi = xg(xi_ind, :);
    
    if size(xi.data, 1) == size(unique(xi.data, 'rows'), 1) || noisevariance > 0.0
        
        % [zpcond, lambda] = stk_predict(algo.model, xi, [], xg);
        [zpcond, lambda] = stk_predict(model_xg, xi_ind, [], []);
        zQ = stk_quadrature(1, algo, zpmean(test_ind), abs(zpvar(test_ind)) + noisevariance);
        losscrit = zeros(algo.Q,1);
        for k = 1:algo.Q     
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

%% PICK THE NEXT EVALUATION POINT
[~, ind_min_samplingcrit] = min(samplingcrit);
xinew = xg(ind_min_samplingcrit, :);

%% DISPLAY SAMPLING CRITERION?
if algo.disp, view_samplingcrit(algo, xg, xi, xinew, samplingcrit, 2, false); end

end %%END stk_optim_crit_SUR


