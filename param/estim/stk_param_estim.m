% STK_PARAM_ESTIM estimates the parameters of a covariance function
%
% CALL: PARAM = stk_param_estim (MODEL, XI, YI, PARAM0)
% CALL: [PARAM, LNV] = stk_param_estim (MODEL, XI, YI, PARAM0)
%
%   estimates the parameters PARAM of the covariance function in MODEL
%   from the data (XI, YI) using the restricted maximum likelihood (ReML)
%   method.  The value PARAM0 is used as a starting point for local
%   optimization.
%
%   The observations are assumed to be noisy if MODEL.lognoisevariance is
%   not -inf. In this case, the variance of the noise is estimated if
%   MODEL.lognoisevariance is nan, and assumed known otherwise. The
%   estimated log-variance is returned as the second output argument LNV
%   (equal to MODEL.lognoisevariance when it is assumed to be known).
%
% CALL: PARAM = stk_param_estim (MODEL, XI, YI)
% CALL: [PARAM, LNV] = stk_param_estim (MODEL, XI, YI)
%
%   does the same thing but uses stk_param_init to provide a starting value
%   automatically.
%
% CALL: [PARAM, LNV] = stk_param_estim (MODEL, XI, YI, PARAM0, LNV0)
%
%   additionally provides an initial guess LNV0 for the logarithm of the
%   noise variance. In this case the observations are automatically assumed
%   to be noisy, and the value of MODEL.lognoisevariance is ignored.
%
% CALL: PARAM = stk_param_estim (MODEL, XI, YI, PARAM0, [], CRIT)
% CALL: [PARAM, LNV] = stk_param_estim (MODEL, XI, YI, PARAM0, LNV0, CRIT)
%
%   uses the estimation criterion CRIT instead of the default ReML criterion.
%
% EXAMPLES: see, e.g., stk_example_kb02, stk_example_kb03, stk_example_kb04,
%           stk_example_kb06, stk_example_misc02

% Copyright Notice
%
%    Copyright (C) 2015-2018 CentraleSupelec
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>
%              Ashwin Ravisankar  <ashwinr1993@gmail.com>
%              Remi Stroh         <remi.stroh@lne.fr>

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

function [param_opt, lnv_opt, info] = stk_param_estim ...
    (model, xi, zi, param0, lnv0, criterion)

% Empty is the same as not provided
if nargin < 6,  criterion = [];  end
if nargin < 5,  lnv0      = [];  end
if nargin < 4,  param0    = [];  end

% size checking: xi, zi
zi_data = double (zi);
if ~ isequal (size (zi_data), [stk_length(xi) 1])
    errmsg = 'zi should be a column, with the same number of rows as xi.';
    stk_error (errmsg, 'IncorrectSize');
end

% Warn about special case: constant response
if (std (zi_data) == 0)
    warning ('STK:stk_param_estim:ConstantResponse', ['Constant-response ' ...
        'data: the output of stk_param_estim is likely to be unreliable.']);
end

% Make sure that lognoisevariance is -inf for noiseless models
if ~ stk_isnoisy (model)
    model.lognoisevariance = -inf;
end

% Should we estimate the variance of the noise, too ?
if ~ isempty (lnv0)
    % lnv0 present => noise variance *must* be estimated
    do_estim_lnv = true;
    if ~isa(lnv0, 'stk_noisemodel') && (isnan (lnv0) || isinf (lnv0))
        stk_error (['Incorrect value for input argumen lnv0. The starting ' ...
            'point for the estimation of lnv must be neither infinite nor ' ...
            'NaN.'], 'InvalidArgument');
    end
else
    % Otherwise, noise variance estimation happens when lnv has NaNs
    lnv0 = model.lognoisevariance;
    do_estim_lnv = any (isnan (stk_get_optimizable_parameters(lnv0)));
end

if do_estim_lnv && (~isa(lnv0, 'stk_noisemodel')) && (~ isscalar (lnv0))
    stk_error (['Estimating the variance of the noise is not possible ' ...
        'in the hetereoscedastic case yet. Sorry.'], 'InvalidArgument');
end

% Default criterion: restricted likelihood (ReML method)
if isempty (criterion)
    criterion = @stk_param_relik;
end

%% Default value for param0 and lnv0
% param0: provide a value (if not provided as input argument)
[param0, lnv0] = provide_param0_value (model, xi, zi, param0, lnv0);

% lnv0: try stk_param_init_lnv if we still have no acceptable value
if do_estim_lnv && (any(isnan (stk_get_optimizable_parameters(lnv0))))
    model.param = param0;
    if isnumeric(lnv0)
        lnv0 = stk_param_init_lnv (model, xi, zi);
    else % if isa(lnv0, 'stk_noisemodel')
        lnv0 = stk_param_init (lnv0, model, xi, zi);
    end
end

%% Define bounds for optimization
% TODO: allow user-defined bounds
if isa(param0, 'stk_covmodel')
    % if param0 is a stk_covmodel, call directly the good
    % stk_param_getdefaultbounds function
    [lb, ub] = stk_param_getdefaultbounds(param0, xi, zi);
else
    [lb, ub] = stk_param_getdefaultbounds(model.covariance_type, param0, xi, zi);
end

% Get vector of numerical parameters
u0 = stk_get_optimizable_parameters(param0);
nbParam_cov = length(u0);

if do_estim_lnv
    [lb_lnv, ub_lnv] = stk_param_getdefaultbounds_lnv (model, lnv0, xi, zi);
    u0_lnv = stk_get_optimizable_parameters (lnv0);
    lb = [lb; lb_lnv];
    ub = [ub; ub_lnv];
    u0 = [u0; u0_lnv];
end
nbParam_lnv = length(u0) - nbParam_cov;

%% If necessary, define equality constraint with matrix
% Constraint such as A*u0 = b
Aconst_eq = [];
bconst_eq = [];

if (isa(param0, 'stk_covmodel') && isa(param0.prior, 'stk_prior_gauss')...
        && any(param0.prior.eigenvals == 0))
    trans = param0.prior.eigenvect;
    mea_trans = trans'*param0.prior.mean;
    
    ind_eq = (param0.prior.eigenvals == 0);	% index of parameters
    %(or linear combination of parameters) which must not move.
    Aconst_eq = [Aconst_eq; [trans(:, ind_eq)', zeros(sum(ind_eq), nbParam_lnv)]];
    bconst_eq = [bconst_eq; mea_trans(ind_eq, 1)];
end

if (do_estim_lnv && isa(lnv0, 'stk_noisemodel')...
        && isa(lnv0.prior, 'stk_prior_gauss') && any(lnv0.prior.eigenvals == 0))
    trans = lnv0.prior.eigenvect;
    mea_trans = trans'*lnv0.prior.mean;
    
    ind_eq = (lnv0.prior.eigenvals == 0);
    Aconst_eq = [Aconst_eq; [zeros(sum(ind_eq), nbParam_cov), trans(:, ind_eq)']];
    bconst_eq = [bconst_eq; mea_trans(ind_eq, 1)];
end

%% Define the function to optimize
model.param = param0;
switch do_estim_lnv
    case false
        f = @(u)(f_ (model, u, xi, zi, criterion));
    case true
        model.lognoisevariance = lnv0;
        f = @(u)(f_with_noise_ (model, u, xi, zi, criterion));
end


%% Optimize
bounds_available = (~ isempty (lb)) && (~ isempty (ub));

if bounds_available
    A = stk_options_get ('stk_param_estim', 'minimize_box');
    [u_opt, crit_opt] = stk_minimize_boxconstrained (A, f, u0, lb, ub, Aconst_eq, bconst_eq);
else
    A = stk_options_get ('stk_param_estim', 'minimize_unc');
    [u_opt, crit_opt] = stk_minimize_unconstrained (A, f, u0);
end

%% Return result
if do_estim_lnv
    index_lnv = (nbParam_cov + 1):length(u_opt);
    lnv_opt = lnv0;          % Return an object with the same class as lnv0
    lnv_opt = stk_set_optimizable_parameters(lnv_opt, u_opt(index_lnv));
    u_opt(index_lnv) = [];
else
    lnv_opt = model.lognoisevariance;
end

% Create parameter object
param_opt = stk_set_optimizable_parameters (model.param, u_opt);

% Create 'info' structure, if requested
if nargout > 2
    info.criterion = criterion;
    info.crit_opt = crit_opt;
    info.lower_bounds = lb;
    info.upper_bounds = ub;
end

end % function

%#ok<*CTCH,*LERR,*SPWRN,*WNTAG>


%--- The objective function ---------------------------------------------------

function [l, dl] = f_ (model, u, xi, zi, criterion)

if stk_isnoisy(model)
    model = stk_set_optimizable_parameters(model,...
        [u; stk_get_optimizable_noise_parameters(model)]);
else
    model = stk_set_optimizable_parameters(model, u);
end

if nargout == 1
    l = criterion (model, xi, zi);
else
    [l, dl] = criterion (model, xi, zi);
end

end % function


function [l, dl] = f_with_noise_ (model, u, xi, zi, criterion)

model = stk_set_optimizable_parameters(model, u);
if nargout == 1
    l = criterion (model, xi, zi);
else
    [l, dl, dln] = criterion (model, xi, zi);
    dl = [dl; dln];
end

end % function


function [param0, lnv0] = provide_param0_value ... % ---------------------------
    (model, xi, zi, param0, lnv0)

% param0: try to use input argument first
if ~ isempty (param0)
    
    % Cast param0 into an object of the appropriate type
    param0 = stk_set_optimizable_parameters (model.param, stk_get_optimizable_parameters(param0));
    
    % Test if param0 contains nans
    if any (isnan (stk_get_optimizable_parameters (param0)))
        warning ('param0 has nans, calling stk_param_init instead');
        param0 = [];
    end
end

% param0: try stk_param_init if we still have no acceptable value
if isempty (param0)
    model.lognoisevariance = lnv0;
    [param0, lnv0] = stk_param_init (model, xi, zi);
end

end % function


%!shared f, xi, zi, NI, param0, param1, model
%!
%! f = @(x)(- (0.8 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)) );
%! DIM = 1;  NI = 20;  box = [-1.0; 1.0];
%! xi = stk_sampling_regulargrid (NI, DIM, box);
%!
%! SIGMA2 = 1.0;  % variance parameter
%! NU     = 4.0;  % regularity parameter
%! RHO1   = 0.4;  % scale (range) parameter
%! param0 = log ([SIGMA2; NU; 1/RHO1]);
%!
%! model = stk_model ('stk_materncov_iso');

%!test  % noiseless
%! zi = stk_feval (f, xi);
%! param1 = stk_param_estim (model, xi, zi, param0);
%! assert (isequal (size (param1), size (param0)))

% We cannot assume a DETERMINISTIC optimization algorithm
% (for some reason, Octave's sqp is not exactly deterministic)

%!test  % same thing, with empty lnv0 (ok)
%! param2 = stk_param_estim (model, xi, zi, param0, []);
%! assert (stk_isequal_tolrel (param2, param1, 1e-2))

%!error  % same thing, with lnv0 == NaN (not ok as a starting point)
%! param2 = stk_param_estim (model, xi, zi, param0, nan);

%!error  % same thing, with lnv0 == -inf (not ok as a starting point)
%! param2 = stk_param_estim (model, xi, zi, param0, -inf);

%!test  % same thing, with explicit value for 'criterion'
%! param2 = stk_param_estim (model, xi, zi, param0, [], @stk_param_relik);
%! assert (stk_isequal_tolrel (param1, param2, 1e-2))

%!test  % noiseless
%! zi = stk_feval (f, xi);
%! param1 = stk_param_estim (model, xi, zi, param0);
%! param2 = stk_param_estim (model, xi, zi, param0, [], @stk_param_relik);
%! % We cannot assume a DETERMINISTIC optimization algorithm
%! % (for some reason, Octave's sqp is not exactly deterministic)
%! assert (stk_isequal_tolrel (param1, param2, 1e-2))

%!test  % noisy
%! NOISE_STD_TRUE = 0.1;
%! NOISE_STD_INIT = 1e-5;
%! zi = zi + NOISE_STD_TRUE * randn(NI, 1);
%! model.lognoisevariance = 2 * log(NOISE_STD_INIT);
%! [param, lnv] = stk_param_estim ...
%!    (model, xi, zi, param0, model.lognoisevariance);

% Incorrect number of input arguments
%!error param = stk_param_estim ()
%!error param = stk_param_estim (model);
%!error param = stk_param_estim (model, xi);

%!test % Constant response
%! model = stk_model ('stk_materncov52_iso');
%! n = 10;  x = stk_sampling_regulargrid (n, 1, [0; 1]);  z = ones (size (x));
%! param = stk_param_estim (model, x, z, model.param);
%! assert ((all (isfinite (param))) && (length (param) == 2));
