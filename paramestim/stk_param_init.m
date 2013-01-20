% STK_PARAM_INIT provides a starting point for stk_param_estim().

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function [param, lnv] = stk_param_init(model, box, noisy)
stk_narginchk(1, 3);

errmsg = 'This function must be adapted to the object-oriented approach...';
stk_error(errmsg, 'NotReadyYet');

xi = model.observations.x;
zi = model.observations.z;

%%% first, default values for arguments 'box' and 'noisy'

if (nargin < 2) || isempty(box),
    box = [min(xi.a); max(xi.a)];
end

if nargin < 3,
    noisy = false;
end

%%% then, each type of covariance is dealt with specifically

switch model.covariance_type
    
    case 'stk_materncov_iso'
        nu = 5/2 * size(xi.a, 2);
        [param, lnv] = paraminit_(xi, zi, box, nu, model.order, noisy);
        
    case 'stk_materncov_aniso'
        nu = 5/2 * size(xi.a, 2);
        xi = stk_normalize(xi, box);
        [param, lnv] = paraminit_(xi, zi, box, nu, model.order, noisy);
        param = [param(1:2); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_materncov32_iso'
        [param, lnv] = paraminit_(xi, zi, box, 3/2, model.order, noisy);
        
    case 'stk_materncov32_aniso'
        xi = stk_normalize(xi, box);
        [param, lnv] = paraminit_(xi, zi, box, 3/2, model.order, noisy);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_materncov52_iso'
        [param, lnv] = paraminit_(xi, zi, box, 5/2, model.order, noisy);
        
    case 'stk_materncov52_aniso'
        xi = stk_normalize(xi, box);
        [param, lnv] = paraminit_(xi, zi, box, 5/2, model.order, noisy);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    otherwise
        errmsg = 'Unsupported covariance type.';
        stk_error(errmsg, 'IncorrectArgument');
end

end % function stk_param_init


function [param, lnv] = paraminit_(xi, yi, box, nu, order, noisy)

model = stk_model('stk_materncov_iso');
model.order = order;

% normalized factors
xi = stk_normalize(xi, box);

% list of possible values for the ratio eta = sigma2_noise / sigma2
if noisy,
    eta_list = 10 .^ (-6:3:0);
else
    eta_list = 1e-10;
end

% list of possible values for the range parameter
rho_list = sqrt(size(box, 2)) * 10 .^ (-2:.5:0);

% try all possible combinations
eta_best    = NaN;
rho_best    = NaN;
sigma2_best = NaN;
aLL_best    = +Inf;
for eta = eta_list
    for rho = rho_list
        % first use sigma2 = 1
        model.param = log([1.0; nu; 1/rho]);
        model.lognoisevariance = log(eta);
        [K, P] = stk_make_matcov(model, xi);
        % estimate sigma2
        % (TODO: use Cholesky ?)
        beta = (P' * (K \ P)) \ (P' * yi.a);
        zi = yi.a - P * beta;
        sigma2 = 1 / (size(xi.a, 1) - length(beta)) * zi' * (K \ zi);
        % now compute the antilog-likelihood
        if sigma2 > 0
            model.param(1) = log(sigma2);
            model.lognoisevariance = log(eta * sigma2);
            aLL = stk_reml(model, xi, yi);
            if ~isnan(aLL) && (aLL < aLL_best)
                eta_best    = eta;
                rho_best    = rho;
                aLL_best    = aLL;
                sigma2_best = sigma2;
            end
            %fprintf('eta = %.2e,  rho = %.2e,  aLL=%.2e\n', eta, rho, aLL);
        end
    end
end

if isinf(aLL_best)
    errmsg = 'Couldn''t find reasonable parameter values... ?!?';
    stk_error(errmsg, 'AlgorithmFailure');
end

param = log([sigma2_best; nu; 1/rho_best]);
lnv = log(eta_best * sigma2_best);

end % function paraminit_
