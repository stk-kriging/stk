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
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
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

function [u_opt,lik] = stk_minimize_boxconstrained (algo, f, u_init, lb, ub)

if nargin>5
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

nabla_f = @(u)(nabla_f_ (f, u));

[u_opt,lik] = feval (algo.sqp, u_init, {f nabla_f}, [] , [], lb, ub, ...
    algo.options.maxiter, algo.options.tol);

end % function


function df = nabla_f_ (f, u)

% Note: with this implementation, f_val is computed twice
%   (once when f is called by sqp, and once again when nabla_f is called)

[ignd, df] = f (u);  %#ok<ASGLU> CG#07

end % function
