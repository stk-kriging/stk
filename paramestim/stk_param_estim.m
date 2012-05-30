% STK_PARAM_ESTIM estimates the parameters of the covariance from data
%
% CALL: paramopt = stk_param_estim( model, param0, xi, yi,...)
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
function paramopt = stk_param_estim(model, xi, yi, param0 )

% TODO: turn param0 into an optional argument
%       => provide a reasonable default choice

% TODO: allow user-defined bounds
[lb, ub] = get_default_bounds(model, param0, xi, yi);

f = @(param)(f_(model, param, xi, yi));

bounds_available = ~isempty(lb) && ~isempty(ub);

% switch according to preferred optimizer
switch stk_select_optimizer(bounds_available)

    case 1, % Octave / sqp
        nablaf = @(param)(nablaf_ (model,param,xi,yi));
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

end


function [l,dl] = f_(model, param, xi, yi)
model.param = param;
[l, dl] = stk_remlqrg(model, xi, yi);
end

function dl = nablaf_(model, param, xi, yi)
model.param = param;
[l_ignored, dl] = stk_remlqrg(model, xi, yi); %#ok<ASGLU>
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