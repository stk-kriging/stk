% STK_OPTIM_TESTMIN_UNC [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
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

function b = stk_optim_testmin_unc (algo)

if nargin == 1
    
    try
        % Starting point
        x_init = 0.0;
        
        [x_opt, obj_opt] = stk_minimize_unconstrained (algo, @objfun, x_init);
        
        assert (abs (x_opt - 0.3) < 1e-2);
        assert (abs (obj_opt - 0.0) < 1e-2);
        
        b = true;
        
    catch %#ok<CTCH>
        
        b = false;
        
    end % try_catch
    
elseif nargin == 0
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
    
elseif nargin > 1    
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
    
end % if

end % function


function [f, df] = objfun (x)

f = (x - 0.3) .^ 2;
df = 2 * (x - 0.3);

end % function


%!shared algo
%! algo = stk_options_get ('stk_param_estim', 'minimize_unc');

%!error b = stk_optim_testmin_unc ();
%!error b = stk_optim_testmin_unc (algo, 33.51);

%!assert (stk_optim_testmin_unc (algo));
%!assert (~ stk_optim_testmin_unc ('dudule'));
