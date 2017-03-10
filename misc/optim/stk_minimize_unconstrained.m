% STK_MINIMIZE_UNCONSTRAINED performs unconstrained minimization
%
% CALL: U_OPT  = stk_minimize_unconstrained (ALGO, F, U_INIT)
%
%   minimizes the objective function F, using algorithm ALGO with starting
%   point U_INIT. The best point found by the algorithm is returned as U_OPT.
%   The value of ALGO can be 'fminsearch', 'octavesqp', or any algorithm object
%   implementing the 'stk_minimize_boxconstrained' method.
%
% CALL: [U_OPT, F_OPT] = stk_minimize_unconstrained (ALGO, F, U_INIT)
%
%   also returns the best objective value F_OPT.
%
% See also stk_minimize_boxconstrained, stk_optim_octavesqp, stk_optim_fminsearch

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function varargout = stk_minimize_unconstrained (algo, varargin)

switch algo
    
    case 'fminsearch'
        algo = stk_optim_fminsearch ();
        
    case 'octavesqp'
        algo = stk_optim_octavesqp ();
        
    otherwise
        stk_error (['The first input argument should be an algorithm ' ...
            'object, implementing the stk_minimize_unconstrained ', ...
            'method.'], 'InvalidArgument');
end

varargout = cell (1, max (1, nargout));
[varargout{:}] = stk_minimize_unconstrained (algo, varargin{:});

end % function


%!test  % Call fminsearch using function name
%! if stk_optim_isavailable ('fminsearch')
%!     assert (stk_optim_testmin_unc ('fminsearch'));
%! end

%!test  % Call fminsearch directly, using algorithm object
%! if stk_optim_isavailable ('fminsearch')
%!     algo = stk_optim_fminsearch ('TolX', 1e-12, 'TolFun', 1e-12);
%!     assert (stk_optim_testmin_unc (algo));
%! end

%!test  % Call sqp using function name
%! if stk_optim_isavailable ('octavesqp')
%!    assert (stk_optim_testmin_unc ('octavesqp'));
%! end

%!test  % Call sqp directly, using algorithm object
%! if stk_optim_isavailable ('octavesqp')
%!    algo = stk_optim_octavesqp ();
%!    assert (stk_optim_testmin_unc (algo));
%! end

%!error assert (stk_optim_testmin_unc ('InexistentOptimizer'));
%!error assert (stk_optim_testmin_unc (100));
