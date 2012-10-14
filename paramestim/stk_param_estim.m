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
% exp(MODEL.noise.lognoisevariance).
%
% EXAMPLES: see example02.m, example03.m, example08.m

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
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
            errmsg = 'Parameter estimation for general noise models is not supported.'
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

if NOISEESTIM % optize wrt to an "extended" vector of parameters
    [lblnv, ublnv] = get_defaultbounds_lnv(model, param0lnv);
    w_lb = [lb; lblnv];
    w_ub = [ub; ublnv];
    w0 = [cparam0; param0lnv];
else % optimize with respect to cparam
    w_lb = lb;
    w_ub = ub;
    w0 = cparam0;
end

switch NOISEESTIM
    case false,
        f = @(param)(f_(model, param));
        nablaf = @(param)(nablaf_ (model, param));
        % note: currently, nablaf is only used with sqp in Octave
    case true,
        f = @(param)(f_with_noise_(model, param));
        nablaf = @(param)(nablaf_with_noise_ (model, param));
end

% switch according to preferred optimizer
switch stk_select_optimizer(bounds_available)
    
    case 1, % Octave / sqp
        w0 = sqp(w0,{f,nablaf},[],[],w_lb,w_ub,[],1e-5);
        
    case 2, % Matlab / fminsearch (Nelder-Mead)
        options = optimset( 'Display', 'iter',                ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6  );
        w0 = fminsearch(f,w0,options);
        
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
        w0 = fmincon(f, w0, [], [], [], [], w_lb, w_ub, [], options);
        
    otherwise
        error('Unexpected value returned by stk_select_optimizer.');
        
end

if NOISEESTIM
    paramlnvopt = w0(end);
    paramopt = w0(1:end-1);
else
    paramopt = w0;
end

end

function [l,dl] = f_(model, u)
model.randomprocess.priorcov.cparam = u;
[l, dl] = stk_reml(model);
end

function dl = nablaf_(model, u)
model.randomprocess.priorcov.cparam = u;
[l_ignored, dl] = stk_reml(model); %#ok<ASGLU>
end

function [l,dl] = f_with_noise_(model, u)
model.randomprocess.priorcov.cparam = u(1:end-1);
model.noise.cov.logvariance  = u(end);
[l, dl, dln] = stk_reml(model);
dl = [dl; dln];
end

function dl = nablaf_with_noise_(model, u)
model.randomprocess.priorcov.cparam = u(1:end-1);
model.noise.cov.logvariance  = u(end);
[l_ignored, dl, dln] = stk_remlqrg(model); %#ok<ASGLU>
dl = [dl; dln];
end


function [lblnv, ublnv] = get_defaultbounds_lnv (model, param0lnv) %#ok<INUSD>
% assume NOISEESTIM
% constants
TOLVAR = 0.5;

% bounds for the variance parameter
empirical_variance = var(model.observations.z.a);
lblnv = log(eps);
ublnv = log(empirical_variance) + TOLVAR;

end


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
%! zi.a = zi.a + NOISE_STD_TRUE * randn(NI, 1);
%! model.lognoisevariance = 2 * log(NOISE_STD_INIT);
%! [param, lnv] = stk_param_estim ...
%!    (model, xi, zi, param0, model.lognoisevariance);

%!% incorrect number of input arguments
%!error param = stk_param_estim()
%!error param = stk_param_estim(model);
%!error param = stk_param_estim(model, xi);
%!error param = stk_param_estim(model, xi, zi);
%!error param = stk_param_estim(model, xi, zi, param0, log(eps), pi);
