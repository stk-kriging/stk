% STK_PARAM_ESTIM estimates the parameters of a covariance function
%
% CALL: PARAM = stk_param_estim (MODEL, XI, YI, PARAM0)
%
%   estimates the parameters PARAM of the covariance function in MODEL
%   from the data (XI, YI) using the restricted maximum likelihood (ReML)
%   method. A starting point PARAM0 must be provided.
%
% CALL: [PARAM, LNV] = stk_param_estim (MODEL, XI, YI, PARAM0, LNV0)
%
%   also estimate the (logarithm of the) noise variance. This form only
%   applies to the case where the observations are assumed noisy. A starting
%   point (PARAM0, LNV0) has to be provided.
%
% CALL: PARAM = stk_param_estim (MODEL, XI, YI, PARAM0, [], CRIT)
% CALL: [PARAM, LNV] = stk_param_estim (MODEL, XI, YI, PARAM0, LNV0, CRIT)
%
%   uses the estimation criterion CRIT instead of the default ReML criterion.
%
% NOTE: known noise variance
%
%   The first form can be used with noisy observations, in which case the
%   variance of the observation noise is assumed to be known (and given by
%   exp (MODEL.lognoisevariance)).
%
% EXAMPLES: see, e.g., stk_example_kb02, stk_example_kb03, stk_example_kb04,
%           stk_example_kb06, stk_example_misc02

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:  Julien Bect        <julien.bect@supelec.fr>
%              Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%              Ashwin Ravisankar  <ashwinr1993@gmail.com>

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

function [paramopt, paramlnvopt, info] = stk_param_estim ...
    (model, xi, zi, param0, param0lnv, criterion)

if nargin > 6,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% size checking: xi, zi
if ~ isequal (size (zi), [size(xi, 1) 1]),
    errmsg = 'zi should be a column, with the same number of rows as xi.';
    stk_error (errmsg, 'IncorrectSize');
end

% Warn about special case: constant response
if (std (double (zi)) == 0)
    warning ('STK:stk_param_estim:ConstantResponse', ['Constant-response ' ...
        'data: the output of stk_param_estim is likely to be unreliable.']);
end

% TODO: turn param0 into an optional argument
%       => provide a reasonable default choice

% Backward compatiblity: accept model structures with missing lognoisevariance
if (~ isfield (model, 'lognoisevariance')) || (isempty (model.lognoisevariance))
    model.lognoisevariance = -inf;
end

% Should we estimate the variance of the noise, too ?
if nargin > 4
    % param0lnv present => noise variance *must* be estimated
    do_estim_lnv = (~ isempty (param0lnv));
else
    % otherwise, noise variance estimation happens when lnv is nan
    do_estim_lnv = (isnan (model.lognoisevariance));
    param0lnv = [];
end

if nargin < 6,
    criterion = @stk_param_relik;
end

% Cast param0 into an object of the appropriate type and size
% and set model.param to the same value
if isfloat (param0)
    % Note: if model.param is an object, this is actually a call to subsasgn()
    % in disguise => parameter classes *must* support this form of indexing.
    model.param(:) = param0;
    param0 = model.param;
else
    if ~ strcmp (class (param0), class (model.param))
        stk_error ('Incorrect type for param0.', 'TypeMismatch');
    else
        model.param = param0;
    end
end

% Ensure that we have a starting point for lnv
if do_estim_lnv && (isempty (param0lnv))   
    param0lnv = stk_param_init_lnv (model, xi, zi);
end

% TODO: allow user-defined bounds
[lb, ub] = stk_param_getdefaultbounds (model.covariance_type, param0, xi, zi);

if do_estim_lnv
    [lblnv, ublnv] = get_default_bounds_lnv (model, param0lnv, xi, zi);
    lb = [lb ; lblnv];
    ub = [ub ; ublnv];
    u0 = [param0(:); param0lnv];
else
    u0 = param0(:);
end

switch do_estim_lnv
    case false,
        f = @(u)(f_ (model, u, xi, zi, criterion));
        nablaf = @(u)(nablaf_ (model, u, xi, zi, criterion));
        % note: currently, nablaf is only used with sqp in Octave
    case true,
        f = @(u)(f_with_noise_ (model, u, xi, zi, criterion));
        nablaf = @(u)(nablaf_with_noise_ (model, u, xi, zi, criterion));
end

bounds_available = (~ isempty(lb)) && (~ isempty(ub));

optim_display_level = stk_options_get ('stk_param_estim', 'optim_display_level');

% switch according to preferred optimizer
optim_num = stk_select_optimizer (bounds_available);
switch optim_num,
    
    case 1, % Octave / sqp
        
        if ~ strcmp (optim_display_level, 'off')
            warning (sprintf (['Ignoring option: ' ...
                'optim_display_level = %s'], optim_display_level));
        end
        
        [u_opt, crit_opt] = sqp (u0, {f, nablaf}, [], [], lb, ub, [], 1e-5);
        
    case {2, 3}, % Matlab
        
        options = optimset ('Display', optim_display_level, ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6);
        
        if optim_num == 2,  % Matlab / fminsearch (Nelder-Mead)
            
            [u_opt, crit_opt] = fminsearch (f, u0, options);
            
        else  % Matlab / fmincon
            
            options = optimset (options, 'GradObj', 'on');
            
            try
                % try to use the interior-point algorithm, which has been
                % found to provide satisfactory results in many cases
                options = optimset (options, 'algorithm', 'interior-point');
            catch
                % the 'algorithm' option does not exist in some old versions of
                % matlab (e.g., version 3.1.1 provided with r2007a)...
                err = lasterror ();
                if ~ strcmpi (err.identifier, ...
                        'matlab:optimset:invalidparamname')
                    rethrow (err);
                end
            end
            
            [u_opt, crit_opt] = fmincon (f, u0, ...
                [], [], [], [], lb, ub, [], options);
            
        end
        
    otherwise,
        
        error ('Unexpected value returned by stk_select_optimizer.');
        
end % switch

if do_estim_lnv
    paramlnvopt = u_opt(end);
    u_opt(end) = [];
else
    paramlnvopt = [];
end

if isfloat (param0)
    % if a floating-point array was provided, return one also
    paramopt = u_opt;
else
    % if an object of some user-defined class was provided, try to return an
    % object of the same class
    try
        paramopt = param0;
        paramopt(:) = u_opt;
    catch
        paramopt = u_opt;
    end
end % if

% Create 'info' structure, if requested
if nargout > 2,
    info.criterion = criterion;
    info.crit_opt = crit_opt;
    info.lower_bounds = lb;
    info.upper_bounds = ub;
end

end % function stk_param_estim ------------------------------------------------

%#ok<*CTCH,*LERR,*SPWRN,*WNTAG>


%--- The objective function and its gradient ----------------------------------

function [l, dl] = f_ (model, u, xi, zi, criterion)

model.param(:) = u;

if nargout == 1,
    l = criterion (model, xi, zi);
else
    [l, dl] = criterion (model, xi, zi);
end

end % function f_


function dl = nablaf_ (model, u, xi, zi, criterion)

model.param(:) = u;
[l_ignored, dl] = criterion (model, xi, zi);  %#ok<ASGLU>

end % function nablaf_


function [l, dl] = f_with_noise_ (model, u, xi, zi, criterion)

model.param(:) = u(1:end-1);
model.lognoisevariance  = u(end);

if nargout == 1,
    l = criterion (model, xi, zi);
else
    [l, dl, dln] = criterion (model, xi, zi);
    dl = [dl; dln];
end

end % function f_with_noise_


function dl = nablaf_with_noise_ (model, u, xi, zi, criterion)

model.param(:) = u(1:end-1);
model.lognoisevariance  = u(end);
[l_ignored, dl, dln] = criterion (model, xi, zi);  %#ok<ASGLU>
dl = [dl; dln];

end % function nablaf_with_noise_


function [lblnv,ublnv] = get_default_bounds_lnv ... % -------------------------
    (model, param0lnv, xi, zi) %#ok<INUSL>

% assume NOISEESTIM
% constants
TOLVAR = 0.5;

% bounds for the variance parameter
empirical_variance = var(zi);
lblnv = log(eps);
ublnv = log(empirical_variance) + TOLVAR;

end % function get_default_bounds_lnv -----------------------------------------


%!shared f, xi, zi, NI, param0, model
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

%!% incorrect number of input arguments
%!error param = stk_param_estim ()
%!error param = stk_param_estim (model);
%!error param = stk_param_estim (model, xi);
%!error param = stk_param_estim (model, xi, zi);
%!error param = stk_param_estim (model, xi, zi, param0, log(eps), @stk_param_relik, pi);

%!test % Constant response
%! model = stk_model ('stk_materncov52_iso');
%! n = 10;  x = stk_sampling_regulargrid (n, 1, [0; 1]);  z = ones (size (x));
%! param = stk_param_estim (model, x, z, model.param);
%! assert ((all (isfinite (param))) && (length (param) == 2));
