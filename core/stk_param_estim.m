% STK_PARAM_ESTIM estimates the parameters of the covariance from data
%
% CALL: paramopt = stk_param_estim( param0, xi, yi, model,...)
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
%    Copyright (C) 2011 SUPELEC
%    Version: 1.0
%    Authors: Julien Bect <julien.bect@supelec.fr>
%             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:     http://sourceforge.net/projects/kriging/
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
function paramopt = stk_param_estim(param0, xi, yi, model)

% TODO: turn param0 into an optional argument
%       => provide a reasonable default choice

% TODO: allow user-defined bounds
[lb, ub] = get_default_bounds( param0, xi, yi, model );

f = @(param)(f_(xi,yi,model,param));

bounds_available = ~isempty(lb) && ~isempty(ub);

% switch according to preferred optimizer
switch stk_select_optimizer(bounds_available)
    
    case 1, % Octave / sqp
        nablaf = @(param)(nablaf_ (xi,yi,model,param));
        paramopt = sqp(param0,{f,nablaf},[],[],lb,ub,[],1e-5);
        
    case 2, % Matlab / fminsearch (Nelder-Mead)
        options = optimset( 'Display', 'iter',                ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6  );
        paramopt = fminsearch(f,param0,options);
        
    case 3, % Matlab / fmincon
        options = optimset( 'Display', 'iter',                ...
            'Algorithm', 'interior-point', 'GradObj', 'on',   ...
            'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6  );
        paramopt = fmincon(f, param0, [], [], [], [], lb, ub, [], options);
        
    otherwise
        error('Unexpected value returned by stk_select_optimizer.');
        
end

% NESTED FUNCTIONS ARE NOT OCTAVE-COMPLIANT !
%     function [l, dl] = f(param)
%         model.param = param;
%         [l, dl] = stk_remlqrg(xi, yi, model);
%     end

end


function [l,dl] = f_(xi,yi,model,param)
model.param = param;
[l, dl] = stk_remlqrg(xi, yi, model);
end

function dl = nablaf_(xi,yi,model,param)
model.param = param;
[l_ignored, dl] = stk_remlqrg(xi, yi, model); %#ok<ASGLU>
end

function [lb,ub] = get_default_bounds(param0, xi, yi, model)

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