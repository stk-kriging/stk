% STK_PARAM_INIT provides a starting point for stk_param_estim().

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
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

function [param, lnv] = stk_param_init (model, box, noisy)

if nargin > 3,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

errmsg = 'This function must be adapted to the object-oriented approach...';
stk_error(errmsg, 'NotReadyYet');

xi = model.observations.x;
zi = model.observations.z;

if ~ isequal (size (zi), [size(xi, 1) 1]),
    errmsg = 'zi should be a column, with the same number of rows as xi.';
    stk_error (errmsg, 'IncorrectSize');
end

%--- first, default values for arguments 'box' and 'noisy' ---------------------

if (nargin < 2) || isempty(box),
    box = [min(xi); max(xi)];
end

if nargin < 3,
    noisy = false;
end

%--- lognoisevariance ? --------------------------------------------------------

if isfield (model, 'lognoisevariance') && ~ isempty (model.lognoisevariance)
    warning (sprintf ('Ignoring current value of lognoisevariance (%.3e)', ...
        model.lognoisevariance), 'IgnoringLogNoiseVariance');
end

%--- linear model --------------------------------------------------------------

lm = model.randomprocess.priormean;

%--- then, each type of covariance is dealt with specifically ------------------

switch model.covariance_type
    
    case 'stk_materncov_iso'
        nu = 5/2 * size (xi, 2);
        [param, lnv] = paraminit_ (xi, zi, box, nu, lm, noisy);
        
    case 'stk_materncov_aniso'
        nu = 5/2 * size (xi, 2);
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], nu, lm, noisy);
        param = [param(1:2); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_materncov32_iso'
        [param, lnv] = paraminit_ (xi, zi, box, 3/2, lm, noisy);
        param = [param(1); param(3)];
        
    case 'stk_materncov32_aniso'
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], 3/2, lm, noisy);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_materncov52_iso'
        [param, lnv] = paraminit_ (xi, zi, box, 5/2, lm, noisy);
        param = [param(1); param(3)];
        
    case 'stk_materncov52_aniso'
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], 5/2, lm, noisy);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_gausscov_iso'
        [param, lnv] = paraminit_ (xi, zi, box, +Inf, lm, noisy);
        param = [param(1); param(3)];
        
    case 'stk_gausscov_aniso'
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], +Inf, lm, noisy);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    otherwise
        errmsg = 'Unsupported covariance type.';
        stk_error (errmsg, 'IncorrectArgument');
end

end % function stk_param_init


function [param, lnv] = paraminit_ (xi, zi, box, nu, lm, noisy)

[ni d] = size (xi);

model = stk_model ('stk_materncov_iso');
model.randomprocess.priormean = lm;

% list of possible values for the ratio eta = sigma2_noise / sigma2
if noisy,
    eta_list = 10 .^ (-6:3:0);
else
    eta_list = 1e-10;
end

% list of possible values for the range parameter
if isempty (box)
    % assume box = repmat([0; 1], 1, d)
    box_diameter = sqrt (d);
else
    box_diameter = sqrt (sum (diff (box) .^ 2));
end
rho_max  = 2 * box_diameter;
rho_min  = box_diameter / 50;
rho_list = logspace (log10 (rho_min), log10 (rho_max), 5);

% try all possible combinations
eta_best    = NaN;
rho_best    = NaN;
sigma2_best = NaN;
aLL_best    = +Inf;
for eta = eta_list
    for rho = rho_list
        fprintf ('[stk_param_init] eta = %.3e, rho = %.3e...\n', eta, rho);
        % first use sigma2 = 1.0
        model.param = log ([1.0; nu; 1/rho]);
        model.lognoisevariance = log (eta);
        [K, P] = stk_make_matcov (model, xi);
        % estimate sigma2
        zi = double (zi);  L = stk_cholcov (K, 'lower');  W = L \ P;
        beta = (W' * W) \ (W' * (L \ zi));
        sigma2 = 1 / (ni - length (beta)) * sum ((L \ (zi - P * beta)) .^ 2);
        % now compute the antilog-likelihood
        if sigma2 > 0
            model.param(1) = log (sigma2);
            model.lognoisevariance = log  (eta * sigma2);
            aLL = stk_param_relik (model, xi, zi);
            if ~isnan(aLL) && (aLL < aLL_best)
                eta_best    = eta;
                rho_best    = rho;
                aLL_best    = aLL;
                sigma2_best = sigma2;
            end
            %fprintf ('eta = %.2e,  rho = %.2e,  aLL=%.2e\n', eta, rho, aLL);
        end
    end
end

if isinf (aLL_best)
    errmsg = 'Couldn''t find reasonable parameter values... ?!?';
    stk_error (errmsg, 'AlgorithmFailure');
end

param = log ([sigma2_best; nu; 1/rho_best]);
lnv = log (eta_best * sigma2_best);

end % function paraminit_


% %!test
% %! xi = (1:10)';  zi = sin (xi);
% %! model = stk_model ('stk_materncov52_iso');
% %! model.param = stk_param_init (model, xi, zi, [1; 10], false);
% %! xt = (1:9)' + 0.5;  zt = sin (xt);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (sum ((zt - zp.mean) .^ 2) < 1e-3);

% %!test  % check equivariance of parameter estimates
% % f = @(x) sin (x); 
% % xi = stk_sampling_regulargrid (10, 1);  zi = stk_feval (f, xi);
% % shift = 1000;  scale = 0.01;
% % model = stk_model ('stk_materncov32_iso');
% % p1 = stk_param_init (model, xi, zi);
% % p2 = stk_param_init (model, xi, shift + scale .* zi);
% % assert (stk_isequal_tolabs (p2(1), p1(1) + log (scale^2), 1e-10))
% % assert (stk_isequal_tolabs (p2(2), p1(2), eps))

%!shared xi zi BOX xt zt
%!
%! f = @(x)(- (0.8 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
%! DIM = 1;               % Dimension of the factor space
%! BOX = [-1.0; 1.0];     % Factor space
%!
%! xi = stk_sampling_regulargrid (20, DIM, BOX);  % Evaluation points
%! zi = stk_feval (f, xi);                        % Evaluation results
%!
%! NT = 400;                                      % Number of points in the grid
%! xt = stk_sampling_regulargrid (NT, DIM, BOX);  % Generate a regular grid
%! zt = stk_feval (f, xt);                        % Values of f on the grid

% %!test
% %! model = stk_model ('stk_materncov_iso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_materncov_aniso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_materncov32_iso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_materncov32_aniso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_materncov52_iso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_materncov52_aniso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_gausscov_iso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

% %!test
% %! model = stk_model ('stk_gausscov_aniso');
% %! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
% %! model.param = stk_param_estim (model, xi, zi, param0);
% %! zp = stk_predict (model, xi, zi, xt);
% %! assert (max ((zp.mean - zt) .^ 2) < 1e-3)
