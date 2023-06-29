% STK_MINIMIZE_BOXCONSTRAINED performs boxconstrained minimisation using sqp.
%
% CALL: U_OPT  = stk_minimize_boxconstrained (ALGO, F, U_INIT, LB, UB)
%
%   estimates the parameters U_OPT within the user-defined lowerbounds LB
%   and upper bounds UB, which gives the minimum value of the function F. A
%   starting point U_INIT must be provided.
%
% CALL: [U_OPT, LIK] = stk_minimize_boxconstrained (ALGO, F, U_INIT, LB, UB)
%
%   also estimates the minimum function value LIK after the boxconstrained
%   minimisation using sqp.
%
% NOTE: Here ALGO is an input argument to the function, that is an object of
% class 'stk_optim_octavesqp'.

% Copyright Notice
%
%    Copyright (C) 2015, 2018, 2021 CentraleSupelec
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
%              Ashwin Ravisankar  <ashwinr1993@gmail.com>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function [u_opt, lik] = stk_minimize_boxconstrained (algo, f, u_init, lb, ub)

% Re-initialize wrapper
f_wrap ();

% Wrap the wrappers
f_ = @(u)(f_wrap (f, u, lb, ub));
df_ = @(u)(df_wrap (f, u, lb, ub));

% sqp is very fragile, so we enclose is in a try-catch block
% (see, notably: https://savannah.gnu.org/bugs/index.php?64369)
try %#ok<TRYNC>
    [u_opt, lik] = feval (algo.sqp, u_init, {f_ df_}, [], [], lb, ub, ...
        algo.options.maxiter, algo.options.tol);  %#ok<ASGLU>
end

% Get u_opt and lik from the wrapper
[lik, ~, u_opt] = f_wrap ();

end % function


function df_val = df_wrap (f, u, lb, ub)

[~, df_val] = f_wrap (f, u, lb, ub);

end % function


function [f_val, df_val, u] = f_wrap (f, u, lb, ub)

persistent u_last u_best f_val_last f_val_best df_val_last df_val_best

% No args => reinit
if nargin == 0

    f_val = f_val_best;
    df_val = df_val_best;
    u = u_best;

    u_last = [];
    u_best = [];
    f_val_last = [];
    f_val_best = Inf;
    df_val_last = [];
    df_val_best = [];

    return
end

if isequal (u, u_last)
    f_val = f_val_last;
    df_val = df_val_last;
    return
end

[f_val, df_val] = f (u);

u_last = u;
f_val_last = f_val;
df_val_last = df_val;

if (f_val < f_val_best) && (all (u >= lb)) && (all (u <= ub))
    u_best = u;
    f_val_best = f_val;
    df_val_best = df_val;
end

end % function
