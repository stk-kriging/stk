% STK_PARAM_ESTIM estimates the parameters of a covariance function.
%
% CALL: PARAM = stk_param_estim(MODEL, XI, YI, PARAM0)
%
%   estimates the parameters PARAM of the covariance function in MODEL from the
%   data (XI, YI) using the rectricted maximum likelihood (ReML) method. A
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

function [paramopt, paramlnvopt] = stk_param_estim ...
    (model, xi, yi, param0, param0lnv)

stk_narginchk(4, 5);

xi = stk_datastruct(xi);
yi = stk_datastruct(yi);
    
% size checking: xi, yi
if size(yi.a, 1) ~= size(xi.a, 1),
    errmsg = 'xi.a and yi.a should have the same number of lines.';
    stk_error(errmsg, 'IncorrectArgument');
end
if size(yi.a, 2) ~= 1,
    errmsg = 'yi.a should be a column vector.';
    stk_error(errmsg, 'IncorrectArgument');
end

% TODO: turn param0 into an optional argument
%       => provide a reasonable default choice

% TODO: think of a better way to tell we want to estimate the noise variance
NOISEESTIM = (nargin == 5);

if NOISEESTIM && ~isfield(model, 'lognoisevariance')
    model.lognoisevariance = param0lnv;
end

% TODO: allow user-defined bounds
[lb, ub] = get_default_bounds(model, param0, xi, yi);

if NOISEESTIM
    [lblnv, ublnv] = get_default_bounds_lnv(model, param0lnv, xi, yi);
    lb = [lb ; lblnv];
    ub = [ub ; ublnv];
    param0 = [param0; param0lnv];
end

switch NOISEESTIM
    case false,
        f = @(param)(f_(model, param, xi, yi));
        nablaf = @(param)(nablaf_ (model, param, xi, yi));
        % note: currently, nablaf is only used with sqp in Octave
    case true,
        f = @(param)(f_with_noise_(model, param, xi, yi));
        nablaf = @(param)(nablaf_with_noise_ (model, param, xi, yi));
end

bounds_available = ~isempty(lb) && ~isempty(ub);

% switch according to preferred optimizer
switch stk_select_optimizer(bounds_available)
    
    case 1, % Octave / sqp
        paramopt = sqp(param0,{f,nablaf},[],[],lb,ub,[],1e-5);
        
    case 2, % Matlab / fminsearch (Nelder-Mead)
        options = optimset( 'Display', 'iter',                ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6  );
        paramopt = fminsearch(f,param0,options);
        
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
        paramopt = fmincon(f, param0, [], [], [], [], lb, ub, [], options);
        
    otherwise
        error('Unexpected value returned by stk_select_optimizer.');
        
end

if NOISEESTIM
    paramlnvopt = paramopt(end);
    paramopt(end) = [];
end

end

function [l,dl] = f_(model, param, xi, yi)
model.param = param;
[l, dl] = stk_remlqrg(model, xi, yi);
end

function dl = nablaf_(model, param, xi, yi)
model.param = param;
[l_ignored, dl] = stk_remlqrg(model, xi, yi); %#ok<ASGLU>
end

function [l,dl] = f_with_noise_(model, param, xi, yi)
model.param = param(1:end-1);
model.lognoisevariance  = param(end);
[l, dl, dln] = stk_remlqrg(model, xi, yi);
dl = [dl; dln];
end

function dl = nablaf_with_noise_(model, param, xi, yi)
model.param = param(1:end-1);
model.lognoisevariance  = param(end);
[l_ignored, dl, dln] = stk_remlqrg(model, xi, yi); %#ok<ASGLU>
dl = [dl; dln];
end

function [lb,ub] = get_default_bounds(model, param0, xi, yi)

% constants
TOLVAR = 5.0;
TOLSCALE = 5.0;

% bounds for the variance parameter
empirical_variance = var(yi.a);
logvar_lb = min(log(empirical_variance), param0(1)) - TOLVAR;
logvar_ub = max(log(empirical_variance), param0(1)) + TOLVAR;

dim = size(xi.a, 2);

switch model.covariance_type,
    
    case {'stk_materncov_aniso', 'stk_materncov_iso'}
        
        nu_lb = min(log(0.5), param0(2));
        nu_ub = max(log(min(50, 10*dim)), param0(2));
        
        range_mid = param0(3:end);
        range_lb  = range_mid(:) - TOLSCALE;
        range_ub  = range_mid(:) + TOLSCALE;
        
        lb = [logvar_lb; nu_lb; range_lb];
        ub = [logvar_ub; nu_ub; range_ub];
        
    case {'stk_materncov32_aniso', 'stk_materncov32_iso', ...
          'stk_materncov52_aniso', 'stk_materncov52_iso'}
        
        range_mid = param0(2:end);
        range_lb  = range_mid(:) - TOLSCALE;
        range_ub  = range_mid(:) + TOLSCALE;
        
        lb = [logvar_lb; range_lb];
        ub = [logvar_ub; range_ub];
        
    otherwise
        
        lb = [];
        ub = [];
        
end

end

function [lblnv,ublnv] = get_default_bounds_lnv ...
    (model, param0lnv, xi, yi) %#ok<INUSL>

% assume NOISEESTIM
% constants
TOLVAR = 0.5;

% bounds for the variance parameter
empirical_variance = var(yi.a);
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
