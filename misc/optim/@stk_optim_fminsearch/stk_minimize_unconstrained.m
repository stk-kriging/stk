% STK_MINIMIZE_UNCONSTRAINED minimizes a function by using fminsearch, with
% no bounds on the input parameters.It takes as inputs, an object belonging to 
% the class stk_optim_fminsearch, the function that needs to be minimized 
% and the starting parameter values and then outputs the optimised parameter 
% values and the minimum value of the function found. 

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

function [u_opt,lik] = stk_minimize_unconstrained (algo, f, u_init)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

[u_opt,lik] = fminsearch (f, u_init, algo.options);

end % function stk_minimize_unconstrained