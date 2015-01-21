% STK_OPTIM_CRIT_IAGO IAGO criterion
%
% CALL: stk_optim_crit_iago()
%
% STK_OPTIM_CRIT_IAGO chooses evaluation point using the IAGO criterion

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function [xinew, zp, CondH ] = stk_optim_crit_iago ( algo, xg, xi_ind, zi )

ng = stk_length(xg);

xi = xg(xi_ind, :);
ni = stk_length(xi);

%% SIMULATION + INITIAL PREDICTION
zsim = stk_generate_samplepaths(algo.model, xg, algo.nsamplepaths);
model_xg = stk_model('stk_discretecov', algo.model, xg);
[zp, lambda] = stk_predict(model_xg, xi_ind, zi, []);
zpmean = zp.mean;
zpvar  = zp.var;

%% ACTIVATE DISPLAY?
if algo.disp; view_init(algo, xi, zi, xg); end

%% COMPUTE THE STEPWISE UNCERTAINTY REDUCTION CRITERION

% allocate sampling criterion vector
CondH = zeros(ng, 1);
CONDH_OK = false;

while ~CONDH_OK
    for test_ind = 1:ng
        if algo.showprogress, progress_disp('  ..', test_ind, ng); end   
        xi_ind(ni+1) = test_ind;
        xi = xg(xi_ind, :);
        
        if strcmp(algo.noise, 'noisefree')
            noisevariance = 0.0;
        else
            model_xg.lognoisevariance = log(xg.noisevariance(xi_ind));
            noisevariance = exp(model_xg.lognoisevariance(ni+1));
        end

        if size(xi.data, 1) == size(unique(xi.data, 'rows'), 1) || noisevariance > 0.0
            
            [~, lambda_] = stk_predict(model_xg, xi_ind, [], []);
            
            zQ = stk_quadrature(1, algo, zpmean(test_ind), abs(zpvar(test_ind)) + noisevariance);
            
            H = zeros(algo.Q,1);
            for k = 1:algo.Q
                
                zi_ =  [zi.data; zQ(k)]; % add a fictitious observation
                
                % condition on the fictitious observation
                zsimc = stk_conditioning(lambda_, zi_, zsim, xi_ind);
                
                [~, ind_maximum] = max(zsimc.data);
            
                % estimate the entropy of the maximizer distribution
                
                F = hist(ind_maximum, 1:ng);
                p = F/algo.nsamplepaths;
                
                H(k) = -sum(p.*log(p+eps));
                
                DEBUG = false;
                if DEBUG && (test_ind==50 || test_ind==140),
                    zz_view_debug_1d(algo, xi, zi_, xg, test_ind, k, H, ind_maximum); end
            end
            
            CondH(test_ind) = stk_quadrature(2, algo, H);
            
        else
            
            xi_ind = xi_ind(1:ni); % drop the test point
            zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
            [~, ind_maximum] = max(zsimc.data);
            F = hist(ind_maximum, 1:ng);
            p = F/algo.nsamplepaths;
            CondH(test_ind) = -sum(p.*log(p+eps));
            
        end
    end % loop over candidate points
    
    CONDH_OK = true;
    
    % 	if any( CondH > max(CondH(xi_ind(1:ni)) + 2e-2*(max(CondH) - min(CondH))) )
    % 		% keyboard
    % 		disp(['Warning: numerical instability detected' ...
    % 			  ' while computing entropy, increasing quadrature order']);
    % 		CONDH_OK = false;
    % 		algo.Q = algo.Q + 100;
    % 		[algo.zQ, algo.wQ] = stk_quadrature(algo.quadtype, algo.Q);
    % 	else
    % 		CONDH_OK = true;
    % 	end
    
end % test if CondH is computed correctly

%% SELECT THE NEXT EVALUATION POINT
[~, ind_min_CondH] = min(CondH);
xinew = xg(ind_min_CondH, :);

%% DISPLAY SAMPLING CRITERION?
if algo.disp, view_samplingcrit(algo, xg, xi, xinew, CondH, 2, false); end

end %%END stk_optim_crit_iago
