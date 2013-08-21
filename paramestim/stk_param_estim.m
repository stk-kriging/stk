% STK_PARAM_ESTIM estimates the parameters of a covariance function.
%
% CALL: PARAM = stk_param_estim(MODEL, XI, YI, PARAM0)
%
%   estimates the parameters PARAM of the covariance function in MODEL from the
%   data (XI, YI) using the restricted maximum likelihood (ReML) method. A
%   starting point PARAM0 has to be provided.
%
% CALL: [PARAM, LNV] = stk_param_estim(MODEL, XI, YI, PARAM0, LNV0)
%
%   also estimate the (logarithm of the) noise variance. This form only applies
%   to the case where the observations are assumed noisy. A starting point
%   (PARAM0, LNV0) has to be provided.
%
% NOTE: the first form can be used with noisy observations, in which case the
% variance of the observation noise is assumed to be known (and given by
% exp(MODEL.lognoisevariance).
%
% EXAMPLES: see example02.m, example03.m, example08.m

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

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

function [paramopt, paramlnvopt] = stk_param_estim ...
    (model, xi, yi, param0, param0lnv)

if nargin > 5,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% size checking: xi, yi
if size(yi, 1) ~= size(xi, 1),
    errmsg = 'xi and yi should have the same number of rows.';
    stk_error(errmsg, 'IncorrectArgument');
end
if size(yi, 2) ~= 1,
    errmsg = 'yi should be a column vector.';
    stk_error(errmsg, 'IncorrectArgument');
end

% TODO: turn param0 into an optional argument
%       => provide a reasonable default choice

% TODO: think of a better way to tell we want to estimate the noise variance
NOISEESTIM = (nargin == 5);

if NOISEESTIM && ~isfield(model, 'lognoisevariance')
    model.lognoisevariance = param0lnv;
end

% Cast param0 into an object of the appropriate type and size
% and set model.param to the same value
if isfloat(param0)
    % Note: if model.param is an object, this is actually a call to subsasgn() in
    % disguise => parameter classes *must* support this form of indexing.
    model.param(:) = param0;
    param0 = model.param;
else
    if ~strcmp(class(param0), class(model.param))
        stk_error('Incorrect type for param0.', 'TypeMismatch');
    else
        model.param = param0;
    end
end

% TODO: allow user-defined bounds
[lb, ub] = stk_param_getdefaultbounds(model.covariance_type, param0, xi, yi);

if NOISEESTIM
    [lblnv, ublnv] = get_default_bounds_lnv(model, param0lnv, xi, yi);
    lb = [lb ; lblnv];
    ub = [ub ; ublnv];
    u0 = [param0(:); param0lnv];
else
    u0 = param0(:);
end

switch NOISEESTIM
    case false,
        f = @(u)(f_(model, u, xi, yi));
        nablaf = @(u)(nablaf_ (model, u, xi, yi));
        % note: currently, nablaf is only used with sqp in Octave
    case true,
        f = @(u)(f_with_noise_(model, u, xi, yi));
        nablaf = @(u)(nablaf_with_noise_ (model, u, xi, yi));
end

bounds_available = ~isempty(lb) && ~isempty(ub);

% switch according to preferred optimizer
switch stk_select_optimizer(bounds_available)
    
    case 1, % Octave / sqp
        u_opt = sqp(u0, {f,nablaf}, [], [], lb, ub, [], 1e-5);
        
    case 2, % Matlab / fminsearch (Nelder-Mead)
        options = optimset( 'Display', 'iter',                ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6  );
        u_opt = fminsearch(f, u0, options);
        
    case 3, % Matlab / fmincon
        try
            % We first try to use the interior-point algorithm, which has
            % been found to provide satisfactory results in many cases
            options = optimset('Display', 'iter', ...
                'Algorithm', 'interior-point', 'GradObj', 'on', ...
                'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6);
        catch
            % The 'Algorithm' option does not exist in some old versions of
            % Matlab (e.g., version 3.1.1 provided with R2007a)...
            err = lasterror();
            if strcmp(err.identifier, 'MATLAB:optimset:InvalidParamName')
                options = optimset('Display', 'iter', 'GradObj', 'on', ...
                    'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6);
            else
                rethrow(err);
            end
        end
        u_opt = fmincon(f, u0, [], [], [], [], lb, ub, [], options);
        
    otherwise
        error('Unexpected value returned by stk_select_optimizer.');
        
end % switch

if NOISEESTIM
    paramlnvopt = u_opt(end);
    u_opt(end) = [];
else
    paramlnvopt = [];
end

if isfloat(param0)
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

end % function stk_param_estim ------------------------------------------------


%--- The objective function and its gradient ----------------------------------

function [l, dl] = f_(model, u, xi, yi)
model.param(:) = u;
if nargout == 1,
    l = stk_remlqrg(model, xi, yi);
else
    [l, dl] = stk_remlqrg(model, xi, yi);
end
end

function dl = nablaf_(model, u, xi, yi)
model.param(:) = u;
[l_ignored, dl] = stk_remlqrg(model, xi, yi); %#ok<ASGLU>
end

function [l, dl] = f_with_noise_(model, u, xi, yi)
model.param(:) = u(1:end-1);
model.lognoisevariance  = u(end);
if nargin == 1,
    l = stk_remlqrg(model, xi, yi);
else
    [l, dl, dln] = stk_remlqrg(model, xi, yi);
    dl = [dl; dln];
end
end

function dl = nablaf_with_noise_(model, u, xi, yi)
model.param(:) = u(1:end-1);
model.lognoisevariance  = u(end);
[l_ignored, dl, dln] = stk_remlqrg(model, xi, yi); %#ok<ASGLU>
dl = [dl; dln];
end

function [lblnv,ublnv] = get_default_bounds_lnv ... % -------------------------
    (model, param0lnv, xi, yi) %#ok<INUSL>

% assume NOISEESTIM
% constants
TOLVAR = 0.5;

% bounds for the variance parameter
empirical_variance = var(yi);
lblnv = log(eps);
ublnv = log(empirical_variance) + TOLVAR;

end % function get_default_bounds_lnv -----------------------------------------


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared f, xi, zi, NI, param0, model
%!
%! f = @(x)( -(0.8*x+sin(5*x+1)+0.1*sin(10*x)) );
%! DIM = 1; NI = 20; box = [-1.0; 1.0];
%! xi = stk_sampling_regulargrid(NI, DIM, box);
%!
%! SIGMA2 = 1.0;  % variance parameter
%! NU     = 4.0;  % regularity parameter
%! RHO1   = 0.4;  % scale (range) parameter
%! param0 = log([SIGMA2; NU; 1/RHO1]);
%!
%! model = stk_model('stk_materncov_iso');

%!test  % noiseless
%! zi = stk_feval(f, xi);
%! param = stk_param_estim(model, xi, zi, param0);

%!test  % noisy
%! NOISE_STD_TRUE = 0.1;
%! NOISE_STD_INIT = 1e-5;
%! zi = zi + NOISE_STD_TRUE * randn(NI, 1);
%! model.lognoisevariance = 2 * log(NOISE_STD_INIT);
%! [param, lnv] = stk_param_estim ...
%!    (model, xi, zi, param0, model.lognoisevariance);

%!% incorrect number of input arguments
%!error param = stk_param_estim()
%!error param = stk_param_estim(model);
%!error param = stk_param_estim(model, xi);
%!error param = stk_param_estim(model, xi, zi);
%!error param = stk_param_estim(model, xi, zi, param0, log(eps), pi);
