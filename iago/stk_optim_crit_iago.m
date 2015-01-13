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

function [xinew, xg, zp, algo, CondH ] = stk_optim_crit_iago ( algo, xi, zi )

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
% if algo.searchgrid_move;
% 	algo = stk_move_the_xg0(algo, xg, xi, xi_ind, zi); end

%% SIMULATION + INITIAL PREDICTION
zsim = stk_generate_samplepaths(algo.model, xg, algo.nsamplepaths);

model_xg = stk_model('stk_discretecov', algo.model, xg);
zp = stk_predict(model_xg, xi_ind, zi, []);

noisevariance = exp(algo.model.lognoisevariance);

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
        
        if size(xi.data, 1) == size(unique(xi.data, 'rows'), 1) || noisevariance > 0.0
            [~, lambda] = stk_predict(model_xg, xi_ind, [], []);
            
            switch algo.quadtype
                case 'GH',
                    zQ = zp.mean(test_ind) + sqrt(2*(abs(zp.var(test_ind)) + noisevariance)) * algo.zQ;
                case {'Linear', 'T'},
                    zQ = zp.mean(test_ind) + sqrt(abs(zp.var(test_ind)) + noisevariance) * algo.zQ;
            end
            H = zeros(algo.Q,1);
            for k = 1:algo.Q
                
                zi(ni+1,:) =  zQ(k); % add a fictitious observation
                
                % condition on the fictitious observation
                zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
                
                [~, ind_maximum] = max(zsimc.data);
                
                % estimate the entropy of the maximizer distribution
                
                F = hist(ind_maximum, 1:ng);
                p = F/algo.nsamplepaths;
                
                H(k) = -sum(p.*log(p+eps));
                
                DEBUG = false;
                if DEBUG && (test_ind==50 || test_ind==140),
                    zz_view_debug_1d(algo, xi, zi, xg, test_ind, k, H, ind_maximum); end
            end
            
            switch algo.quadtype
                case 'GH',
                    CondH(test_ind) = 1/sqrt(pi) * sum(algo.wQ.*H);
                case 'Linear',
                    CondH(test_ind) = algo.wQ(1) * sum(H);
                case 'T',
                    CondH(test_ind) = sum(algo.wQ .* H);
            end
        else
            xi_ind = xi_ind(1:ni); % drop the test point
            zi = zi(1:ni,:);
            [~, lambda] = stk_predict(model_xg, xi_ind, [], []);
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
