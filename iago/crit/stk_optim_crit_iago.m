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

function [zc_pred, CondH ] = stk_optim_crit_iago (algo, xi, zi)

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
zg_sim0 = stk_generate_samplepaths (model_xg, (1:ng)', algo.nsamplepaths);
[zg_pred, lambda] = stk_predict (model_xg, xi_ind, zi, []);

% Return predictions on candidate points only
zc_pred = zg_pred((ni + 1):end, :);


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
zg_simc = stk_conditioning (lambda, zi, zg_sim0, xi_ind, noise_sim);
zc_simc = zg_simc((ni + 1):end, :);

% Discrete distribution of the maximizer
[~, ind_maximum] = max (zc_simc);
p = (hist (ind_maximum, 1:nc)) / algo.nsamplepaths;

% Compute current entropy
p_log_p = p .* (log (p));
p_log_p(p < 1e-300) = 0;
H_current = - sum (p_log_p);

if algo.disp,  stk_optim_crit_iago_view_;  end


%% COMPUTE THE STEPWISE UNCERTAINTY REDUCTION CRITERION

% We don't want any fancy object in here
xi = double (xi);  zi = double (zi);  zg_sim0 = double (zg_sim0);

% Allocate sampling criterion vector
CondH = zeros (nc, 1);
CONDH_OK = false;

% Define std tolerance
% FIXME: numerical constant should go in the options
std_tol = (max (zc_pred.mean) - median (zc_pred.mean)) * 1e-10;

while ~CONDH_OK
    for ic = 1:nc
        
        if algo.showprogress,
            stk_disp_progress ('  ..', ic, nc);
        end
        
        % Index of candidate point in xg
        ind_candi = ni + ic;
        
        % Noise variance
        lnv = get_lognoisevariance (algo.model, algo.xg0, ic, true);
        if isinf (algo.futurebatchsize),
            % The future new observation will be noiseless
            noisevariance = 0;
            lnv = - inf;
        else
            % Get the lnv for the future new observation
            noisevariance = (exp (lnv)) / algo.futurebatchsize;
            lnv = log (noisevariance);
        end        
        
        % Heteroscedastic case: store lnv in model.lognoisevariance
        % (because we called stk_fakenorep, model_.lognoisevariance is a vector)
        model_ = model_xg;
        model_.lognoisevariance = [model_.lognoisevariance; lnv];
        
        % Do not sample again a point where the value is already known
        % with a very high accuracy (according to the model)
        if (sqrt (zc_pred.var(ic))) < std_tol
            
            % No change of entropy if we sample this point again
            CondH(ic) = H_current;
            
        else
            
            % Compute prediction weight with ni + 1 points
            [~, lambda_] = stk_predict (model_, [xi_ind; ind_candi], [], []);
            
            % Compute the part of zsimc that does not depend on k
            delta = bsxfun (@minus, zi, zg_sim0(xi_ind, :));
            if (~ isempty (noise_sim))  % Noisy case ?
                delta = delta - noise_sim;
            end
            zg_simc = zg_sim0 + lambda_(1:ni, :)' * delta;
            
            % Compute quadrature points
            zQ = stk_quadrature (1, algo, zc_pred.mean(ic), ...
                zc_pred.var(ic) + 2 * noisevariance);
            
            H = zeros(algo.quadorder,1);
            for k = 1:algo.quadorder
                
                % Finish the computation of zsimc
                delta = zQ(k) - zg_sim0(ind_candi, :);
                z_simc_ = zg_simc + lambda_(ni + 1, :)' * delta;
                
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
    % 		algo.quadorder = algo.quadorder + 100;
    % 		[algo.zQ, algo.wQ] = stk_quadrature(algo.quadtype, algo.quadorder);
    % 	else
    % 		CONDH_OK = true;
    % 	end
    
end


%% DISPLAY SAMPLING CRITERION?
if algo.disp,
    [~, ind_min_CondH] = min(CondH);  xinew = xc(ind_min_CondH, :);  %%%TEMP
    view_samplingcrit(algo, xc, xi, xinew, CondH, 2);
end

end %%END stk_optim_crit_iago



%--- view_current --------------------------------------------------------------
%
% Some visualization related to the current state of affairs
%   (meaning: before the computation of the CEM sampling criterion)
%
% [we use evalin ('caller', ...) since Octave does not support nested functions]

function stk_optim_crit_iago_view_ ()

[algo, ni, xi, zi, xc, zc_pred, zc_simc, p] = evalin ...
    ('caller', 'deal (algo, ni, xi, zi, xc, zc_pred, zc_simc, p);');

% Count calls
persistent count_calls
if isempty (count_calls),  count_calls = 0;  end
count_calls = count_calls + 1;

% Display only once in a while
if mod (count_calls - 1, algo.disp_period) ~= 0,
    return;
end

% Figure XX01: Prediction & conditional samplepaths
if algo.dim == 1,
    stk_optim_crit_fig01 (algo, xi, zi, xc, zc_pred, zc_simc);
end

% Figure XX02: Distribution of the maximizer
stk_optim_crit_fig02 (algo, xc, p);

end % function view_current
