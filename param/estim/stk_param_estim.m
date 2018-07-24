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
%    Copyright (C) 2017 LNE
%    Copyright (C) 2014 A. Ravisankar
%    Copyright (C) 2011-2014 SUPELEC
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

% Empty is the same as 'not provided'
if nargin < 6
    criterion = [];
    if nargin < 5
        lnv0 = [];
        if nargin < 4
            param0 = [];
        end
    end
end

% Size checking: xi, zi
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

% Default criterion: restricted likelihood (ReML method)
if isempty (criterion)
    criterion = @stk_param_relik;
end

% Make sure that we have a starting point in (param0, lnv0)
[param0, lnv0, do_estim_lnv] = provide_starting_point (model, xi, zi, param0, lnv0);

% TODO: allow user-defined bounds
[lb, ub] = stk_param_getdefaultbounds (model.covariance_type, param0, xi, zi);

% Get vector of numerical parameters
u0 = stk_get_optimizable_parameters (param0);
nbParam_cov = length (u0);

if do_estim_lnv
    [lb_lnv, ub_lnv] = stk_param_getdefaultbounds_lnv (model, lnv0, xi, zi);
    u0_lnv = stk_get_optimizable_parameters (lnv0);
    lb = [lb; lb_lnv];
    ub = [ub; ub_lnv];
    u0 = [u0; u0_lnv];
end

model.param = param0;
switch do_estim_lnv
    case false
        f = @(u)(f_ (model, u, xi, zi, criterion));
    case true
        model.lognoisevariance = lnv0;
        f = @(u)(f_with_noise_ (model, u, xi, zi, criterion));
end

bounds_available = (~ isempty (lb)) && (~ isempty (ub));

if bounds_available
    A = stk_options_get ('stk_param_estim', 'minimize_box');
    [u_opt, crit_opt] = stk_minimize_boxconstrained (A, f, u0, lb, ub);
else
    A = stk_options_get ('stk_param_estim', 'minimize_unc');
    [u_opt, crit_opt] = stk_minimize_unconstrained (A, f, u0);
end

if do_estim_lnv
    index_lnv = (nbParam_cov + 1):length(u_opt);
    lnv_opt = lnv0;          % Return an object with the same class as lnv0
    lnv_opt = stk_set_optimizable_parameters (lnv_opt, u_opt(index_lnv));
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


function [param0, lnv0, do_estim_lnv] = provide_starting_point ...
    (model, xi, zi, param0, lnv0)

% The starting points param0 and lnv0 can be provided either directly under the
% form of a vector of a numeric parameters, or as parameter objects.  Both cases
% are covered thanks to the use of stk_get_optimizable_parameters.

% If param0 is not empty, it means that the user has provided
% a starting point, in which case we must use it.
if ~ isempty (param0)
    
    param0_ = stk_get_optimizable_parameters (param0);
    
    % Test if param0 contains nans
    if any (isnan (param0_))
        stk_error ('param0 has NaNs', 'InvalidArgument');
    end
    
    % Cast param0 into a variable of the appropriate type (numeric or object)
    param0 = stk_set_optimizable_parameters (model.param, param0_);
    
    % Now take care of lnv0.
    % Same rule: if not empty, we have a user-provided starting point.
    if isempty (lnv0)
        % When lnv0 is not provided, noise variance estimation happens when lnv has NaNs.
        do_estim_lnv = any (isnan (stk_get_optimizable_noise_parameters (model)));
        if do_estim_lnv
            % We have a user-provided starting point for param0 but not for lnv0.
            model.param = param0;
            if isnumeric (model.lognoisevariance)
                lnv0 = stk_param_init_lnv (model, xi, zi);
            else
                % EXPERIMENTAL (Stroh)
                lnv0 = stk_param_init (model.lognoisevariance, model, xi, zi);
            end
        end
    else
        % When lnv0 is provided, noise variance *must* be estimated
        do_estim_lnv = true;
        stk_param_check_lnv0 (model, lnv0);
    end
    
else  % Otherwise, try stk_param_init to get a starting point
    
    if isempty (lnv0)
        % If needed, stk_param_init will also provide a starting point for lnv0
        % (This is triggered by the presence of NaNs.)
        do_estim_lnv = any (isnan (stk_get_optimizable_noise_parameters (model)));
    else
        % When lnv0 is provided, noise variance *must* be estimated
        do_estim_lnv = true;
        stk_param_check_lnv0 (model, lnv0);
        % In this case stk_param_init will return lnv0 = model.lognoisevariance,
        % so we just have to set our starting point there.
        lnv0_ = stk_get_optimizable_parameters (lnv0);
        model.lognoisevariance = stk_set_optimizable_parameters ...
            (model.lognoisevariance, lnv0_);
    end
    
    [param0, lnv0] = stk_param_init (model, xi, zi);
    
end % if

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
%! param = stk_param_estim (model, x, z);
%! assert ((all (isfinite (param))) && (length (param) == 2));
