% STK_MINIMIZE_UNCONSTRAINED performs unconstrained minimisation using sqp.
%
% CALL: U_OPT  = stk_minimize_unconstrained (ALGO, F, U_INIT)
%
%   estimates the parameters U_OPT without any bounds, which gives the minimum
%   value of the function F. A starting point U_INIT must be provided.
%
% CALL: [U_OPT, LIK] = stk_minimize_unconstrained (ALGO, F, U_INIT)
%
%   also estimates the minimum function value LIK after the unconstrained
%   minimisation using sqp.
%
% NOTE: Here ALGO is an input argument to the function, that is an object of
% class 'stk_optim_octavesqp'.

% Copyright Notice
%
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

function [u_opt,lik] = stk_minimize_unconstrained (algo, f, u_init)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

[u_opt, lik] = stk_minimize_boxconstrained (algo, f, u_init, [], []);

end % function
