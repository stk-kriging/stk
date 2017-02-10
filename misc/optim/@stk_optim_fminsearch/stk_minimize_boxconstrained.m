% STK_MINIMIZE_BOXCONSTRAINED [overload STK function]
%
% CALL: [U_OPT, LIK] = stk_minimize_boxconstrained (ALGO, F, U_INIT, LB, UB)
%
% NOTE
%
%    This function simply ignores the bounds, since fminsearch does not handle
%    them.  This is provided as a last recourse for Matlab users that have
%    neither the Optimization toolbox nor MOSEK.

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function [u_opt, lik] = stk_minimize_boxconstrained (algo, f, u_init, lb, ub)

if nargin > 5
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

persistent already_warned

if isempty (already_warned)
    
    w_id = 'STK:stk_optim_fminsearch:stk_minimize_boxconstrained:BoxIgnored';
    
    warning (['STK is going to use fminsearch for a box-constrained ' ...
        'optimization problem.  There is no guarantee that the solution '   ...
        'will be inside the box.  You should consider getting a proper '    ...
        'box-constrained optimizer.']);
    
    % Even if the persistent gets cleared, don't display the warning again.
    % This trick allows us to avoid mlock'ing the file.
    warning ('off', w_id);
    
    already_warned = 1;
end

[u_opt, lik] = stk_minimize_unconstrained (algo, f, u_init);

end % function


%#ok<*INUSD>  % lb and ub are ignored on purpose
