% STK_PARAM_ESTIM estimates the parameters of the covariance from data
%
% CALL: paramopt = stk_param_estim( model, xi, yi, param0 ...)
%
% STK_PARAM_ESTIM helper function to estimate the parameters of a
% covariance from data using rectricted maximum likelihood
%
% FIXME: documentation incomplete
%
% EXAMPLE: see examples/example02.m

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect <julien.bect@supelec.fr>
%               Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function [paramopt, paramlnvopt] = stk_param_estim(model, xi, yi, param0, param0lnv)

% TODO: turn param0 into an optional argument
%       => provide a reasonable default choice

% TODO: think of a better way to tell we want to estimate the noise
% variance
NOISYOBS   = isfield( model, 'lognoisevariance' );
if nargin == 5
    NOISEESTIM = true;
else
    NOISEESTIM  = false;
end
if ~NOISYOBS, 
    if NOISEESTIM,
        error('Please set lognoisevariance in model...');
    end
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
        nablaf = @(param)(nablaf_ (model, param, xi, yi)); % only used in Octave
    case true, 
        f = @(param)(f_with_noise_(model, param, xi, yi));
        nablaf = @(param)(nablaf_with_noise_ (model, param, xi, yi)); % only used in Octave
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
lbv = min(log(empirical_variance) - TOLVAR, param0(1));
ubv = max(log(empirical_variance) + TOLVAR, param0(1));

% FIXME: write an function stk_get_dim() to do this
dim = size( xi.a, 2 );

switch model.covariance_type,

    case {'stk_materncov_aniso', 'stk_materncov_iso'}

        lbnu = min(log(0.5), param0(2));
        ubnu = max(log(4*dim), param0(2));

        scale = param0(3:end);
        lba = scale(:) - TOLSCALE;
        uba = scale(:) + TOLSCALE;

        lb = [lbv; lbnu; lba];
        ub = [ubv; ubnu; uba];

    case {'stk_materncov52_aniso', 'stk_materncov52_iso'}

        scale = param0(2:end);
        lba = scale(:) - TOLSCALE;
        uba = scale(:) + TOLSCALE;

        lb = [lbv; lba];
        ub = [ubv; uba];

    otherwise

        lb = [];
        ub = [];

end

end

function [lblnv,ublnv] = get_default_bounds_lnv(model, param0lnv, xi, yi) %#ok<INUSL>
% assume NOISEESTIM
% constants
TOLVAR = 0.5;

% bounds for the variance parameter
empirical_variance = var(yi.a);
lblnv = log(eps);
ublnv = log(empirical_variance) + TOLVAR;

end
