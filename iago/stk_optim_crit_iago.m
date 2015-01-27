% STK_OPTIM_CRIT_IAGO IAGO criterion
%
% CALL: stk_optim_crit_iago()
%
% STK_OPTIM_CRIT_IAGO chooses evaluation point using the IAGO criterion

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec & Ivana Aleksovska
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function [xinew, zp, CondH ] = stk_optim_crit_iago (algo, xi, zi)

% Backward compatiblity: accept model structures with missing lognoisevariance
if (~ isfield (algo.model, 'lognoisevariance')) ...
        || (isempty (algo.model.lognoisevariance))
    algo.model.lognoisevariance = - inf;
end

% === SAFETY NET ===
assert (noise_params_consistency (algo, xi));


%% SIMULATION + INITIAL PREDICTION

ni = stk_length (xi);  xi_ind = 1:ni;

xc = algo.xg0;  nc = stk_length (xc);  % candidate points
xg = [xi; xc];  ng = ni + nc;          % evaluations points & candidate points

model_xg = stk_model ('stk_discretecov', algo.model, xg);
zsim = stk_generate_samplepaths (model_xg, (1:ng)', algo.nsamplepaths);
[zp, lambda] = stk_predict (model_xg, xi_ind, zi, []);

if algo.disp,  view_init (algo, xi, zi, xg);  end


%% COMPUTE THE STEPWISE UNCERTAINTY REDUCTION CRITERION

% allocate sampling criterion vector
CondH = zeros (nc, 1);
CONDH_OK = false;

while ~CONDH_OK
    for ic = 1:nc
        
        if algo.showprogress,
            stk_disp_progress ('  ..', ic, nc);
        end
        
        xi_ind(ni + 1) = ni + ic;
        xi = xg(xi_ind, :);
        
        % Noise variance
        lnv = get_lognoisevariance (algo.model, algo.xg0, ic, true);
        noisevariance = exp (lnv);
        
        % Heteroscedastic case: store lnv in model.lognoisevariance
        model_ = model_xg;
        if isa (xg, 'stk_ndf')  % heteroscedastic case
            model_.lognoisevariance = [model_.lognoisevariance; lnv];
        end
        
        if size(xi.data, 1) == size(unique(xi.data, 'rows'), 1) || noisevariance > 0.0
            
            [~, lambda_] = stk_predict(model_, xi_ind, [], []);
            
            zQ = stk_quadrature (1, algo, zp.mean(ni + ic), ...
                zp.var(ni + ic) + noisevariance);
            
            H = zeros(algo.Q,1);
            for k = 1:algo.Q
                
                zi_ =  [zi.data; zQ(k)]; % add a fictitious observation
                
                % condition on the fictitious observation
                zsimc = stk_conditioning(lambda_, zi_, zsim, xi_ind);
                
                [~, ind_maximum] = max(zsimc);
                
                % estimate the entropy of the maximizer distribution
                
                F = hist(ind_maximum, 1:ng);
                p = F/algo.nsamplepaths;
                
                p_log_p = p .* (log (p));
                p_log_p(p < 1e-300) = 0;
                
                H(k) = - sum (p_log_p);
                
            end
            
            CondH(ic) = stk_quadrature(2, algo, H);
            
        else
            
            xi_ind = xi_ind(1:ni); % drop the test point
            zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
            [~, ind_maximum] = max (zsimc);
            
            F = hist(ind_maximum, 1:ng);
            p = F/algo.nsamplepaths;
            
            p_log_p = p .* (log (p));
            p_log_p(p < 1e-300) = 0;
            
            CondH(ic) = - sum (p_log_p);
            
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
xinew = xc(ind_min_CondH, :);

%% DISPLAY SAMPLING CRITERION?
if algo.disp,
    view_samplingcrit(algo, xc, xi, xinew, CondH, 2);
end

end %%END stk_optim_crit_iago
