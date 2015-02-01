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

ni = stk_length (xi);  xi_ind = (1:ni)';

xc = algo.xg0;  nc = stk_length (xc);  % candidate points
xg = [xi; xc];  ng = ni + nc;          % evaluations points & candidate points

if algo.disp,  view_init (algo, xi, zi, xg);  end

model_xg = stk_model ('stk_discretecov', algo.model, xg);
[model_xg, zi] = stk_fakenorep (model_xg, zi);
z_sim0 = stk_generate_samplepaths (model_xg, (1:ng)', algo.nsamplepaths);
[zp, lambda] = stk_predict (model_xg, xi_ind, zi, []);


%% Compute current entropy

% Simulate observation noise
%  (note: this should be done by stk_generate_samplepaths)
if any (model_xg.lognoisevariance ~= -inf)
    noise_sim = bsxfun (@times, ...
        exp (0.5 * model_xg.lognoisevariance), ...
        randn (ni, algo.nsamplepaths));
else
    noise_sim = [];
end

% Simulate samplepaths
z_simc = stk_conditioning (lambda, zi, z_sim0, xi_ind, noise_sim);

% Discrete distribution of the maximizer
[~, ind_maximum] = max (z_simc((ni + 1):end, :));
p = (hist (ind_maximum, 1:nc)) / algo.nsamplepaths;

% Compute current entropy
p_log_p = p .* (log (p));
p_log_p(p < 1e-300) = 0;
H_current = - sum (p_log_p);


%% COMPUTE THE STEPWISE UNCERTAINTY REDUCTION CRITERION

% We don't want any fancy object in here
xi = double (xi);  zi = double (zi);
xg = double (xg);  z_sim0 = double (z_sim0);

% allocate sampling criterion vector
CondH = zeros (nc, 1);
CONDH_OK = false;

while ~CONDH_OK
    for ic = 1:nc
        
        if algo.showprogress,
            stk_disp_progress ('  ..', ic, nc);
        end
        
        % Index of candidate point in xg
        ind_candi = ni + ic;
        
        % Noise variance
        lnv = get_lognoisevariance (algo.model, algo.xg0, ic, true);
        noisevariance = exp (lnv);
        
        % Heteroscedastic case: store lnv in model.lognoisevariance
        % (because we called stk_fakenorep, model_.lognoisevariance is a vector)
        model_ = model_xg;
        model_.lognoisevariance = [model_.lognoisevariance; lnv];
        
        if (ismember (xg(ind_candi, :), xi, 'rows')) && (noisevariance == 0.0)
            
            % No change of entropy if we sample this point again
            CondH(ic) = H_current;
            
        else
            
            % Compute prediction weight with ni + 1 points
            [~, lambda_] = stk_predict (model_, [xi_ind; ind_candi], [], []);
            
            % Compute the part of zsimc that does not depend on k
            delta = bsxfun (@minus, zi, z_sim0(xi_ind, :));
            if (~ isempty (noise_sim))  % Noisy case ?
                delta = delta - noise_sim;
            end
            z_simc = z_sim0 + lambda_(1:ni, :)' * delta;
            
            % Compute quadrature points
            zQ = stk_quadrature (1, algo, zp.mean(ind_candi), ...
                zp.var(ind_candi) + noisevariance);
            
            H = zeros(algo.Q,1);
            for k = 1:algo.Q
                
                % Finish the computation of zsimc
                delta = zQ(k) - z_sim0(ind_candi, :);
                if noisevariance > 0
                    delta = delta - (sqrt (noisevariance)) ...
                        * (randn (1, algo.nsamplepaths));
                end
                z_simc_ = z_simc + lambda_(ni + 1, :)' * delta;
                
                % estimate the entropy of the maximizer distribution
                [~, ind_maximum] = max(z_simc_((ni + 1):end, :));
                p = (hist (ind_maximum, 1:nc)) / algo.nsamplepaths;
                p_log_p = p .* (log (p));
                p_log_p(p < 1e-300) = 0;
                H(k) = - sum (p_log_p);
                
            end
            
            CondH(ic) = stk_quadrature(2, algo, H);
            
        end
    end % loop over candidate points
    
    CONDH_OK = true;
    
    % 	if any( CondH > max(CondH(xi_ind) + 2e-2*(max(CondH) - min(CondH))) )
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
