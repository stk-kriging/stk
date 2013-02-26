% STK_PARAM_ESTIM estimates the parameters of a covariance function.
%
% CALL: PARAM = stk_param_estim(MODEL, PARAM0)
%
%   estimates the parameters PARAM of the covariance function in MODEL from the
%   data MODEL.observations using the rectricted maximum likelihood (ReML) method.
%   A starting point PARAM0 has to be provided.
%
% CALL: [PARAM, LNV] = stk_param_estim(MODEL, PARAM0, LNV0)
%
%   also estimate the (logarithm of the) noise variance. This form only applies
%   to the case where the observations are assumed noisy. A starting point
%   (PARAM0, LNV0) has to be provided.
%
% NOTE: the first form can be used with noisy observations, in which case the
% variance of the observation noise is assumed to be known (and given by
% MODEL.noise.cov.variance).
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

function [paramopt, paramlnvopt] = stk_param_estim (model, cparam0, param0lnv)

stk_narginchk(1, 3);

% TODO: think of a better way to tell we want to estimate the noise variance
NOISEESTIM = (nargin == 3);

if NOISEESTIM,
    % check if estimating the noise variance is possible
    switch class(model.noise.cov)
        case 'stk_nullcov'  % noiseless observations
            stk_error('Please set model.noise...', 'IncorrectArgument');
        case 'stk_homnoisecov'
            % ok, we can handle it
        otherwise
            errmsg = ['Parameter estimation for general noise models ' ...
                'is not supported.'];
            stk_error(errmsg, 'IncorrectArgument');
    end
end

if (nargin < 2) || isempty(cparam0),
    cparam0 = model.randomprocess.priorcov.cparam;
end

% TODO: allow user-defined bounds
[lb, ub] = stk_get_defaultbounds( ...
    model.randomprocess.priorcov, cparam0, model.observations.z);

bounds_available = ~isempty(lb) && ~isempty(ub);

if NOISEESTIM % optimize wrt to an "extended" vector of parameters
    [lblnv, ublnv] = get_defaultbounds_lnv(model, param0lnv);
    w_lb = [lb; lblnv];
    w_ub = [ub; ublnv];
    w0 = [cparam0(:); param0lnv];
else % optimize with respect to cparam
    w_lb = lb;
    w_ub = ub
    w0 = cparam0(:);
end

switch NOISEESTIM
    case false,
        f = @(w)(f_(model, w));
        nablaf = @(w)(nablaf_ (model, w));
        % note: currently, nablaf is only used with sqp in Octave
    case true,
        f = @(w)(f_with_noise_(model, w));
        nablaf = @(w)(nablaf_with_noise_ (model, w));
end

% switch according to preferred optimizer
switch stk_select_optimizer(bounds_available)
    
    case 1, % Octave / sqp
        w_opt = sqp(w0, {f, nablaf}, [], [], w_lb, w_ub, [], 1e-5);
        
    case 2, % Matlab / fminsearch (Nelder-Mead)
        options = optimset( 'Display', 'iter',                ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6  );
        w_opt = fminsearch(f, w0, options);
        
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
            err = lasterror(); %#ok<LERR>
            if strcmp(err.identifier, 'MATLAB:optimset:InvalidParamName')
                options = optimset('Display', 'iter', 'GradObj', 'on', ...
                    'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6);
            else
                rethrow(err);
            end
        end
        w_opt = fmincon(f, w0, [], [], [], [], w_lb, w_ub, [], options);
        
    otherwise
        error('Unexpected value returned by stk_select_optimizer.');
        
end % switch

if NOISEESTIM
    paramlnvopt = w_opt(end);
    w_opt = w_opt(1:end-1);
end

if isfloat(cparam0)
    % if a floating-point array was provided, return one also
    paramopt = w_opt;
else
    % if an object of some user-defined class was provided, try to return an
    % object of the same class
    try
        paramopt = cparam0;
        paramopt(:) = w_opt;
    catch %#ok<CTCH>
        paramopt = w_opt;
    end
end % if

end % function stk_param_estim ------------------------------------------------


%--- The objective function and its gradient ----------------------------------

function [l, dl] = f_(model, w)
model.randomprocess.priorcov.cparam = w;
[l, dl] = stk_reml(model);
end

function dl = nablaf_(model, w)
model.randomprocess.priorcov.cparam = w;
[l_ignored, dl] = stk_reml(model); %#ok<ASGLU>
end

function [l, dl] = f_with_noise_(model, w)
model.randomprocess.priorcov.cparam = w(1:end-1);
model.noise.cov.variance = exp(w(end));
[l, dl, dln] = stk_reml(model);
dl = [dl; dln];
end

function dl = nablaf_with_noise_(model, w)
model.randomprocess.priorcov.cparam = w(1:end-1);
model.noise.cov.variance = exp(w(end));
[l_ignored, dl, dln] = stk_reml(model); %#ok<ASGLU>
dl = [dl; dln];
end


function [lblnv, ublnv] = get_defaultbounds_lnv ... %--------------------------
    (model, param0lnv) %#ok<INUSD>

% assume NOISEESTIM
% constants
TOLVAR = 0.5;

% bounds for the variance parameter
empirical_variance = var(model.observations.z.a);
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
%! zi = stk_feval(f, xi);
%!
%! SIGMA2 = 1.0;  % variance parameter
%! NU     = 4.0;  % regularity parameter
%! RHO1   = 0.4;  % scale (range) parameter
%! param0 = log([SIGMA2; NU; 1/RHO1]);
%!
%! model = stk_model('stk_materncov_iso');

%!test  % noiseless
%! model = stk_setobs(model, xi, zi);
%! param = stk_param_estim(model, param0);

%!test  % noiseless
%! model = stk_setobs(model, xi, stk_feval(f, xi));
%! model.randomprocess.priorcov.param = param0;
%! param = stk_param_estim(model);

%!test  % noisy
%! NOISE_STD_TRUE = 0.1;
%! NOISE_STD_INIT = 1e-5;
%! zi.a = zi.a + NOISE_STD_TRUE * randn(NI, 1);
%! model = stk_setobs(model, xi, zi);
%! model.noise.cov = stk_homnoisecov(NOISE_STD_INIT^2);
%! [param, lnv] = stk_param_estim(model, param0, 2 * log(NOISE_STD_INIT));

%!% incorrect number of input arguments
%!error param = stk_param_estim()
%!error param = stk_param_estim(model, param0, log(eps), pi);
