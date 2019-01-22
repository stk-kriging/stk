% STK_PARAM_ESTIM_OPTIMIZE [STK internal]
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal.  API-breaking
%    changes are very likely to happen in future releases.

% Copyright Notice
%
%    Copyright (C) 2015-2018 CentraleSupelec
%    Copyright (C) 2014 Ashwin Ravisankar
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>
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

function [model_opt, info] = stk_param_estim_optim ...
    (model0, xi, zi, criterion, covparam_select, noiseparam_select)

select = [covparam_select; noiseparam_select];

% Starting point
v0 = stk_get_optimizable_parameters (model0);
w0 = v0(select);

% Bounds
% FIXME: this could (should) be implemented directly for models
[covparam_lb, covparam_ub] = stk_param_getdefaultbounds (model0.covariance_type, model0.param, xi, zi);
[covparam_lb, covparam_ub] = select_bounds (covparam_lb, covparam_ub, covparam_select);
[noiseparam_lb, noiseparam_ub] = stk_param_getdefaultbounds_lnv (model0, model0.lognoisevariance, xi, zi);
[noiseparam_lb, noiseparam_ub] = select_bounds (noiseparam_lb, noiseparam_ub, noiseparam_select);
lb = [covparam_lb; noiseparam_lb];
ub = [covparam_ub; noiseparam_ub];

% Define objective function
f = @(v)(crit_wrapper (model0, v, xi, zi, criterion, covparam_select, noiseparam_select));

bounds_available = (~ isempty (lb)) && (~ isempty (ub));

if bounds_available
    A = stk_options_get ('stk_param_estim', 'minimize_box');
    [w_opt, crit_opt] = stk_minimize_boxconstrained (A, f, w0, lb, ub);
else
    A = stk_options_get ('stk_param_estim', 'minimize_unc');
    [w_opt, crit_opt] = stk_minimize_unconstrained (A, f, w0);
end

% Create outputs
v_opt = v0;
v_opt(select) = w_opt;
model_opt = stk_set_optimizable_parameters (model0, v_opt);

% Create 'info' structure, if requested
if nargout > 1
    info.criterion = criterion;
    info.crit_opt = crit_opt;
    info.starting_point = w0;
    info.final_point = w_opt;
    info.lower_bounds = lb;
    info.upper_bounds = ub;
    info.param_select = covparam_select;
    info.noiseparam_select = noiseparam_select;
end

end % function

%#ok<*CTCH,*LERR,*SPWRN,*WNTAG>


function [C, dC] = crit_wrapper ...
    (model, w, xi, zi, criterion, covparam_select, noise_select)

v = stk_get_optimizable_parameters (model);
v([covparam_select; noise_select]) = w;
model = stk_set_optimizable_parameters (model, v);

if nargout == 1
    
    % Compute only the value of the criterion
    C = criterion (model, xi, zi);
    
elseif any (noise_select)
    
    % Compute the value of the criterion and the gradients
    % FIXME: We might be computing a lot of derivatives that we don't really need...
    [C, dC_param, dC_lnv] = criterion (model, xi, zi);
    
    dC = [dC_param(covparam_select); dC_lnv(noise_select)];
    
else
    
    % Compute the value of the criterion and the gradients
    % FIXME: We might be computing a lot of derivatives that we don't really need...
    [C, dC_param] = criterion (model, xi, zi);
    
    dC = dC_param(covparam_select);
    
end

end % function


function [lb, ub] = select_bounds (lb, ub, select)

if ~ isempty (lb)
    lb = lb(select);
end

if ~ isempty (ub)
    ub = ub(select);
end

end % function
