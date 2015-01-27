% STK_PARAM_INIT provides a starting point for stk_param_estim
%
% CALL: PARAM = stk_param_init (MODEL, XI, YI)
%
%   provides a quick and dirty estimate of the parameters of MODEL based on the
%   data (XI, YI), that can be used as a starting point for stk_param_estim. It
%   selects the maximizer of the ReML criterion out of a list of possible values
%   given data (XI, YI). This syntax is appropriate for noiseless observations
%   and for noisy observations with known noise variance (i.e., when the
%   'lognoisevariance' field in MODEL is either -Inf or has a finite value).
%
% CALL: [PARAM, LNV] = stk_param_init (MODEL, XI, YI)
%
%   also returns a value for the 'lognoisevariance' field. In the case of
%   noiseless observations or noisy observations with known noise variance, this
%   is simply the value that was provided by the user in MODEL.lognoisevariance.
%   In the case where MODEL.lognoisevariance is NaN (noisy observation with
%   unknown noise variance), LNV is estimated by stk_param_init together with
%   PARAM.
%
% CALL: [PARAM, LNV] = stk_param_init (MODEL, XI, YI, BOX)
%
%   takes into account the (hyper-rectangular) domain on which the model is
%   going to be used. It is used in the heuristics that determines the list of
%   parameter values mentioned above. BOX should be a 2 x DIM matrix with BOX(1,
%   j) and BOX(2, j) being the lower- and upper-bound of the interval on the
%   j^th coordinate, with DIM being the dimension of XI, DIM = size(XI,2). If
%   provided,  If missing or empty, the BOX argument defaults to [min(XI);
%   max(XI)].
%
% CALL: [PARAM, LNV] = stk_param_init (MODEL, XI, YI, BOX, DO_ESTIM_LNV)
%
%   with DO_ESTIM_LNV = TRUE forces the estimation of the variance of the noise,
%   regardless of the value of MODEL.lognoisevariance. If FALSE, it prevents
%   estimation of the variance of the noise, which is only possible if the
%   'lognoisevariance' field in MODEL is either -Inf or has a finite value.
%
% See also stk_example_kb02, stk_example_kb03, stk_example_misc03

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC & IRT SystemX
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@supelec.fr>
%              Paul Feliot  <paul.feliot@irt-systemx.fr>

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

function [param, lnv] = stk_param_init (model, xi, zi, box, do_estim_lnv)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if ~ isequal (size (zi), [size(xi, 1) 1]),
    errmsg = 'zi should be a column, with the same number of rows as xi.';
    stk_error (errmsg, 'IncorrectSize');
end

%--- first, default values for arguments 'box' and 'noisy' ---------------------

if nargin < 5,
    noisy = false;
    if nargin < 4,
        box = [];
    end
end

if ~ isa (box, 'stk_hrect')
    if isempty (box),
        box = stk_boundingbox (xi);  % Default: bounding box
    else
        box = stk_hrect (box);
    end
end

%--- lognoisevariance ? --------------------------------------------------------

% Backward compatiblity: accept model structures with missing lognoisevariance
if (~ isfield (model, 'lognoisevariance')) || (isempty (model.lognoisevariance))
    model.lognoisevariance = - inf;
end

lnv = model.lognoisevariance;

% Estimation of noise variance ?
%  * if do_estim_lnv is provided, use it to decide
%  * if not, estimation occurs when lnv is nan
if nargin < 5
    do_estim_lnv = isnan (lnv);
end
    
if do_estim_lnv
    lnv = nan;
elseif isnan (lnv)        
    stk_error  (sprintf ...
        (['do_estim_lnv is false, but model.lognoisevariance ' ...
        ' is nan.\n If you don''t want the noise variance to be ' ...
        'estimated, you must provide a value for it!']), ...
        'MissingParameterValue');
end

if (isnan (lnv)) && (nargout < 2)
    warning (['stk_param_init will be computing an estimation of the ' ...
        'variance of the noise, perhaps should you call the function ' ...
        'with two output arguments?']);
end
    
%--- linear model --------------------------------------------------------------

if isnan (model.order),
    
    lm = model.lm;
    
else
    
    switch model.order
        case -1, % 'simple' kriging
            lm = stk_lm_null;
        case 0, % 'ordinary' kriging
            lm = stk_lm_constant;
        case 1, % affine trend
            lm = stk_lm_affine;
        case 2, % quadratic trend
            lm = stk_lm_quadratic;
        otherwise, % syntax error
            error ('model.order should be in {-1,0,1,2}');
    end
    
end

%--- then, each type of covariance is dealt with specifically ------------------

switch model.covariance_type
    
    case 'stk_materncov_iso'
        nu = 5/2 * size (xi, 2);
        [param, lnv] = paraminit_ (xi, zi, box, nu, lm, lnv);
        
    case 'stk_materncov_aniso'
        nu = 5/2 * size (xi, 2);
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], nu, lm, lnv);
        param = [param(1:2); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_materncov32_iso'
        [param, lnv] = paraminit_ (xi, zi, box, 3/2, lm, lnv);
        param = [param(1); param(3)];
        
    case 'stk_materncov32_aniso'
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], 3/2, lm, lnv);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_materncov52_iso'
        [param, lnv] = paraminit_ (xi, zi, box, 5/2, lm, lnv);
        param = [param(1); param(3)];
        
    case 'stk_materncov52_aniso'
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], 5/2, lm, lnv);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    case 'stk_gausscov_iso'
        [param, lnv] = paraminit_ (xi, zi, box, +Inf, lm, lnv);
        param = [param(1); param(3)];
        
    case 'stk_gausscov_aniso'
        xi = stk_normalize (xi, box);
        [param, lnv] = paraminit_ (xi, zi, [], +Inf, lm, lnv);
        param = [param(1); param(3) - log(diff(box, [], 1))'];
        
    otherwise
        errmsg = 'Unsupported covariance type.';
        stk_error (errmsg, 'IncorrectArgument');
end

end % function stk_param_init


function [param, lnv] = paraminit_ (xi, zi, box, nu, lm, lnv)

% Check for special case: constant response
if (std (double (zi)) == 0)
    warning ('STK:stk_param_init:ConstantResponse', ...
        'Parameter estimation is impossible with constant-response data.');
    param = [0 log(nu) 0];  if isnan (lnv), lnv = 0; end
    return  % Return some default values
end

d = size (xi, 2);

model = stk_model ('stk_materncov_iso');
model.order = nan;  model.lm = lm;
model.lognoisevariance = lnv;

% list of possible values for the ratio eta = sigma2_noise / sigma2
if lnv ~= -inf
    eta_list = 10 .^ (-6:3:0);
else
    eta_list = 0;
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

% Initialize parameter search
eta_best    = NaN;
rho_best    = NaN;
sigma2_best = NaN;
aLL_best    = +Inf;

% Try all possible combinations of rho and eta from the lists
for eta = eta_list
    for rho = rho_list
        
        % First use sigma2 = 1.0
        model.param = [0.0, log(nu), -log(rho)];
        
        % The same code works for the noiseless case and for the case where lnv
        % must be estimated (in the first case, eta = 0 and thus lnv is -inf)
        if (eta == 0) || (isnan (lnv))
            model.lognoisevariance = log (eta);      
            [beta_ignored, sigma2] = stk_param_gls (model, xi, zi);  %#ok<ASGLU>
            if ~ (sigma2 > 0), continue; end
            log_sigma2 = log (sigma2);
            model.lognoisevariance = log  (eta * sigma2);
        else
            model.param = [0.0, log(nu), -log(rho)];
            log_sigma2 = lnv - (log (eta));
            sigma2 = exp (log_sigma2);
        end
        
        % Now, compute the antilog-likelihood
        model.param(1) = log_sigma2;
        aLL = stk_param_relik (model, xi, zi);
        if ~isnan(aLL) && (aLL < aLL_best)
            eta_best    = eta;
            rho_best    = rho;
            aLL_best    = aLL;
            sigma2_best = sigma2;
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


%!test
%! xi = (1:10)';  zi = sin (xi);
%! model = stk_model ('stk_materncov52_iso');
%! model.param = stk_param_init (model, xi, zi, [1; 10], false);
%! xt = (1:9)' + 0.5;  zt = sin (xt);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (sum ((zt - zp.mean) .^ 2) < 1e-3);

%!test  % check equivariance of parameter estimates
%! f = @(x) sin (x);
%! xi = stk_sampling_regulargrid (10, 1);  zi = stk_feval (f, xi);
%! shift = 1000;  scale = 0.01;
%! model = stk_model ('stk_materncov32_iso');
%! p1 = stk_param_init (model, xi, zi);
%! p2 = stk_param_init (model, xi, shift + scale .* zi);
%! assert (stk_isequal_tolabs (p2(1), p1(1) + log (scale^2), 1e-10))
%! assert (stk_isequal_tolabs (p2(2), p1(2), eps))

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

%!test
%! model = stk_model ('stk_materncov_iso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_materncov_aniso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_materncov32_iso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_materncov32_aniso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_materncov52_iso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_materncov52_aniso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_gausscov_iso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!test
%! model = stk_model ('stk_gausscov_aniso');
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!shared model, x, z
%! model = stk_model ('stk_materncov52_iso');
%! n = 10;  x = stk_sampling_regulargrid (n, 1, [0; 1]);  z = ones (size (x));

%!test % Constant response, noiseless model
%! [param, lnv] = stk_param_init (model, x, z);
%! assert ((all (isfinite (param))) && (length (param) == 2));
%! assert (isequal (lnv, -inf));

%!test % Constant response, noisy model
%! model.lognoisevariance = nan;
%! [param, lnv] = stk_param_init (model, x, z);
%! assert ((all (isfinite (param))) && (length (param) == 2));
%! assert (isscalar (lnv) && isfinite (lnv));
