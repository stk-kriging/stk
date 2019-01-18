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
%    Copyright (C) 2015, 2016, 2018 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
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

function [param, lnv] = stk_param_init (model, varargin)

stk_assert_model_struct (model);

cov_list = { ...
    'stk_expcov_iso', ...
    'stk_expcov_aniso', ...
    'stk_gausscov_iso', ...
    'stk_gausscov_aniso', ...
    'stk_materncov_iso', ...
    'stk_materncov_aniso', ...
    'stk_materncov32_iso', ...
    'stk_materncov32_aniso', ...
    'stk_materncov52_iso', ...
    'stk_materncov52_aniso', ...
    'stk_sphcov_iso', ...
    'stk_sphcov_aniso'};

if ~ ischar (model.covariance_type)
    % Assume that model.covariance_type is a handle
    model.covariance_type = func2str (model.covariance_type);
end

if (ismember (model.covariance_type, cov_list)) && (isnumeric (model.param))
    
    % An initialization for this covariance type is provided in STK
    [param, lnv] = stk_param_init_ (model, varargin{:});
    
else
    try
        % Undocumented feature: make it possible to define a XXXX_param_init
        %  function that provides initial estimates for a user-defined
        %  covariance function called XXXX.
        fname = [model.covariance_type '_param_init'];
        if nargout == 2
            [param, lnv] = feval (fname, model, varargin{:});
        else
            param = feval (fname, model, varargin{:});
        end
    catch
        err = lasterror ();
        msg = strrep (err.message, sprintf ('\n'), sprintf ('\n|| ')); %#ok<SPRINTFN>
        msg = sprintf (['Unable to initialize covariance parameters ' ...
            'automatically for covariance functions of type ''%s''.\n\nThe ' ...
            'original error message was:\n|| %s\n'], model.covariance_type, msg);
        stk_error (msg, 'UnableToInitialize');
    end % try_catch
end % if

end % function

%#ok<*CTCH,*LERR>


function [param, lnv] = stk_param_init_ (model, xi, zi, box, do_estim_lnv)

% Used by stk_model
if nargin < 2
    
    if isa (model.covariance_type, 'function_handle')
        covariance_name = func2str (model.covariance_type);
    else
        covariance_name = model.covariance_type;
    end

    switch covariance_name
        
        % Matern covariance function with unknown regularity
        
        case 'stk_materncov_iso'
            param = nan (3, 1);
        case 'stk_materncov_aniso'
            param = nan (2 + model.dim, 1);
            
        % Other isotropic covariance functions
        
        case {'stk_expcov_iso', 'stk_materncov32_iso', ...
                'stk_materncov52_iso', 'stk_gausscov_iso', ...
                'stk_sphcov_iso'}
            param = nan (2, 1);
        
        % Other anisotropic covariance functions

        case {'stk_expcov_aniso', 'stk_materncov32_aniso', ...
                'stk_materncov52_aniso', 'stk_gausscov_aniso', ...
                'stk_sphcov_aniso'}
            param = nan (1 + model.dim, 1);
        
        otherwise
            stk_error ('Unexpected covariance name', 'IncorrectArgument');
    end
    
    lnv = - inf;
    return
end


%--- check dimensions ----------------------------------------------------------

dim = size (xi, 2);
if isfield (model, 'dim') && ~ isequal (dim, model.dim)
    errmsg = 'model.dim and size (xi, 2) should be equal.';
    stk_error (errmsg, 'IncorrectSize');
end

if ~ isequal (size (zi), [size(xi, 1) 1])
    errmsg = 'zi should be a column, with the same number of rows as xi.';
    stk_error (errmsg, 'IncorrectSize');
end


%--- first, default values for arguments 'box' and 'noisy' ---------------------

if nargin < 4
    box = [];
end

if ~ isa (box, 'stk_hrect')
    if isempty (box)
        box = stk_boundingbox (xi);  % Default: bounding box
    else
        box = stk_hrect (box);
    end
end


%--- backward compatiblity -----------------------------------------------------

% Missing lognoisevariance field
if ~ isfield (model, 'lognoisevariance')
    
    if (nargin < 5) || (~ do_estim_lnv)
        % Assume a noiseless model
        model.lognoisevariance = - inf;
    else
        % Special case: assume a noisy model with constant but unknown noise variance
        model.lognoisevariance = nan;
    end
    
elseif isequal (model.lognoisevariance, -inf) && ((nargin >= 5) && do_estim_lnv)
    
    % In this special case, we are flexible and consider -inf as a particular
    % value of the variance in an homoscedastic noise model.
    model.lognoisevariance = nan;
    
end

% Ensure backward compatiblity with respect to model.order / model.lm
model = stk_model_fixlm (model);


%--- lognoisevariance ? --------------------------------------------------------

lnv_ = stk_get_optimizable_noise_parameters (model);

if isempty (lnv_)
    
    % There are no parameters to optimize in the noise model, either because we
    % are in the noiseless case, ou because we have a noise model object that
    % does not declare any hyperparameter.  In this case:
    
    % Even is do_estim_lnv was set to true by the caller, we set it back
    % to false in this case, since there are no parameters to optimize
    do_estim_lnv = false;
    
    if stk_isnoisy (model)
        lnv = log (stk_covmat_noise (model, xi, [], -1, true));
    else
        lnv = -inf;
    end
    
elseif nargin < 5
    
    % When do_estim_lnv is not set by the user, we set it to true if some
    % of the parameters are NaNs, which is interpreted as "Estimate me !"
    do_estim_lnv = any (isnan (lnv_));
    
    lnv = model.lognoisevariance;
    
else  % do_estim_lnv set by the caller
    
    do_estim_lnv = logical (do_estim_lnv);
    
    if (~ do_estim_lnv) && (any (isnan (lnv_)))
        stk_error (sprintf (['do_estim_lnv is false, but some parameter '    ...
            'values are equal to NaN. If you don''t want the parameters of ' ...
            'the noise variance model to be estimated, you must provide '    ...
            'values for them!']), 'MissingParameterValue');
    end
    
    lnv = model.lognoisevariance;
    
end

% After this point, we only accept
%   a) a scalar lnv (noiseless and homoscedastic cases), which is allowed to be nan,
%   b) a vector lnv (heteroscedatic case), which cannot be nan.
%
% In other words, fancy objects are not allowed, and parameter estimation is
% only supported in the homoscedastic case.  Here we go:
if ~ (isnumeric (lnv) && (isscalar (lnv) || ~ any (isnan (lnv))))
    stk_error (['Parameter estimation for the noise model is ' ...
        'not supported in this case.'], 'InvalidArgument');
end

if (do_estim_lnv) && (nargout < 2)
    warning (['stk_param_init will be computing an estimation of the ' ...
        'variance of the noise, perhaps should you call the function ' ...
        'with two output arguments?']);
end


%--- then, each type of covariance is dealt with specifically ------------------

switch model.covariance_type
    
    case {'stk_expcov_iso', 'stk_materncov32_iso', 'stk_materncov52_iso', ...
            'stk_gausscov_iso', 'stk_sphcov_iso'}
        model0 = model;
        bbox = box;
        
    case {'stk_expcov_aniso', 'stk_materncov32_aniso', ...
            'stk_materncov52_aniso', 'stk_gausscov_aniso', 'stk_sphcov_aniso'}
        covname_iso = [model.covariance_type(1:end-5) 'iso'];
        model0 = stk_model (covname_iso, dim);
        xi = stk_normalize (xi, box);
        bbox = [];
        
    case 'stk_materncov_iso'
        nu = 5/2 * dim;
        model0 = stk_model (@stk_materncov_iso, dim);
        model0.covariance_type = @(param, x, y, diff, pairwise) ...
            stk_materncov_iso ([param(1) log(nu) param(2)], x, y, diff, pairwise);
        model0.param(2) = [];
        bbox = box;
        
    case 'stk_materncov_aniso'
        nu = 5/2 * dim;
        model0 = stk_model (@stk_materncov_iso, dim);
        model0.covariance_type = @(param, x, y, diff, pairwise) ...
            stk_materncov_iso ([param(1) log(nu) param(2)], x, y, diff, pairwise);
        model0.param(2) = [];
        xi = stk_normalize (xi, box);
        bbox = [];
        
    otherwise
        errmsg = 'Unsupported covariance type.';
        stk_error (errmsg, 'InvalidArgument');
end

model0.lognoisevariance = lnv;
[param, lnv] = paraminit_ (model0, xi, zi, bbox);

% Back to a full vector of covariance parameters
switch model.covariance_type
    
    case {'stk_expcov_aniso', 'stk_materncov32_aniso', ...
            'stk_materncov52_aniso', 'stk_gausscov_aniso', 'stk_sphcov_aniso'}
        param = [param(1); param(2) - log(diff(box, [], 1))'];
        
    case 'stk_materncov_iso'
        param = [param(1); log(nu); param(2)];
        
    case 'stk_materncov_aniso'
        param = [param(1); log(nu); param(2) - log(diff(box, [], 1))'];
end

% Return the original lnv if no parameter estimation was performed
if ~ do_estim_lnv
    lnv = model.lognoisevariance;
end

end % function


function [param, lnv] = paraminit_ (model, xi, zi, box)

lnv = model.lognoisevariance;

% Check for special case: constant response
if (std (double (zi)) == 0)
    warning ('STK:stk_param_init:ConstantResponse', ...
        'Parameter estimation is impossible with constant-response data.');
    param = [0 0];  if any (isnan (lnv)), lnv = 0; end
    return  % Return some default values
end

d = size (xi, 2);

% Homoscedastic case ?
homoscedastic = (isscalar (lnv));
noiseless = homoscedastic && (lnv == -inf);

% list of possible values for the ratio eta = sigma2_noise / sigma2
if ~ noiseless
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
        model.param = [0.0, -log(rho)];
        
        if noiseless
            
            [ignd, sigma2] = stk_param_gls (model, xi, zi);  %#ok<ASGLU> CG#07
            if ~ (sigma2 > 0), continue; end
            log_sigma2 = log (sigma2);
            
        elseif homoscedastic && (isnan (lnv))  % Unknown noise variance
            
            model.lognoisevariance = log (eta);
            [ignd, sigma2] = stk_param_gls (model, xi, zi);  %#ok<ASGLU> CG#07
            if ~ (sigma2 > 0), continue; end
            log_sigma2 = log (sigma2);
            model.lognoisevariance = log  (eta * sigma2);
            
        else % Known variance(s)
            
            log_sigma2 = (mean (lnv)) - (log (eta));
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

param = log ([sigma2_best; 1/rho_best]);

if (isscalar (lnv)) && (isnan (lnv))
    % Homoscedatic case with unknown variance... Here is our estimate:
    lnv = log (eta_best * sigma2_best);
end

end % function


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

%!shared xi, zi, BOX, xt, zt
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

%!test  % Homoscedastic case / do_estim_lnv = true
%! model = stk_model ('stk_materncov32_iso');
%! [model.param, model.lognoisevariance] = ...
%!     stk_param_init (model, xi, zi, BOX, true);
%! [model.param, model.lognoisevariance] = ...
%!     stk_param_estim (model, xi, zi);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (model.lognoisevariance > -inf);
%! assert (max ((zp.mean - zt) .^ 2) < 1e-3)

%!error  % Homoscedastic case / do_estim_lnv = false / model.lnv = nan
%! model = stk_model ('stk_materncov32_iso');
%! model.lognoisevariance = nan;  % not compatible with do_estim_lnv == false
%! [model.param, model.lognoisevariance] = ...
%!     stk_param_init (model, xi, zi, BOX, false);

%!test  % Heteroscedastic case / known noise variance
%! model = stk_model ('stk_materncov32_iso');
%! lnv = log ((100 + rand (size (zi))) / 1e6);
%! model.lognoisevariance = lnv;  % here we say that lnv is known
%! [param0, model.lognoisevariance] = stk_param_init (model, xi, zi, BOX);
%! model.param = stk_param_estim (model, xi, zi, param0);
%! zp = stk_predict (model, xi, zi, xt);
%! assert (isequal (model.lognoisevariance, lnv));  % should be untouched
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
