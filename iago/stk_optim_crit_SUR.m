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
    algo.model.param = stk_param_estim (algo.model, xi, zi, algo.model.param);
    fprintf('done\n');
end

%% SEARCH GRID
ni = stk_length(xi);
if algo.searchgrid_unique
    [xg, ~, ixg] = unique([xi.data; algo.xg0.data], 'rows');
    xg = stk_dataframe(xg);
    ng = stk_length(xg);
    xi_ind = ixg(1:ni);
else
    xg = [xi; algo.xg0];
    ng = stk_length(xg);
    xi_ind = 1:ni;
end
if algo.searchgrid_adapt;
	algo = stk_move_the_xg0(algo, xg, xi, xi_ind, zi); end

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
    
    switch algo.quadtype
        case 'GH',
            zQ = zpmean(test_ind) + sqrt(2*(abs(zpvar(test_ind)) + noisevariance)) * algo.zQ;
        case {'Linear', 'T'},
            zQ = zpmean(test_ind) + sqrt(abs(zpvar(test_ind)) + noisevariance) * algo.zQ;
    end
    
    xi_ind(ni+1) = test_ind;
    % xi = xg(xi_ind, :);
    % [zpcond, lambda] = stk_predict(algo.model, xi, [], xg);
    [zpcond, lambda] = stk_predict(model_xg, xi_ind, [], []);
    
    losscrit = zeros(algo.Q,1);
    for k = 1:algo.Q
        
        zi_ =  [zi.data; zQ(k)]; % add a fictitious observation      
        zpm = lambda' * zi_;
        
        switch(type)
            case 1 % EI
                Mn = max(zi_);
                losscrit(k) = -Mn;
            case 2 % EI with Mn = max(zp)
                Mn = max(zpm);
                losscrit(k) = -Mn;
            case 3 % EEI
                Mn = max(zi_);
                expected_excess = stk_distrib_normal_ei(Mn, zpm, sqrt(zpcond.var));
                losscrit(k) = 1/ng*sum(expected_excess);
            case 4 % EEI with Mn = max(zp)
                Mn = max(zpm);
                expected_excess = stk_distrib_normal_ei(Mn, zpm, sqrt(zpcond.var));
                losscrit(k) = 1/ng*sum(expected_excess);
        end
        
    end
    
    switch algo.quadtype
        case 'GH',
            samplingcrit(test_ind) = 1/sqrt(pi) * sum(algo.wQ.*losscrit);
        case 'Linear',
            samplingcrit(test_ind) = algo.wQ(1) * sum(losscrit);
        case 'T',
            samplingcrit(test_ind) = sum(algo.wQ.*losscrit);
    end
    
end

%% PICK THE NEXT EVALUATION POINT
[~, ind_min_samplingcrit] = min(samplingcrit);
xinew = xg(ind_min_samplingcrit, :);

%% DISPLAY SAMPLING CRITERION?
if algo.disp, view_samplingcrit(algo, xg, xi, xinew, samplingcrit, 2, false); end

end %%END stk_optim_crit_SUR


