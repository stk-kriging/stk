% STK_MINIMIZE_BOXCONSTRAINED minimizes a function by using sqp, with
% bounds on the input parameters.It takes as inputs, an object belonging to 
% the class stk_optim_octavesqp, the function that needs to be minimized, 
% starting parameter values and the lower and upper bounds on the parameters
% and then outputs the optimised parameter values and the minimum value of 
% the function found.

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%
%    Authors:  Julien Bect        <julien.bect@supelec.fr>
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

[u_opt,lik] = sqp (u_init, {f nabla_f}, [] , [], lb, ub, ...
    algo.options.maxiter, algo.options.tol);

end % function stk_minimize_boxconstrained


function df = nabla_f_ (f, u)

[f_val, df] = f (u);  %#ok<ASGLU>

end % function nabla_f_