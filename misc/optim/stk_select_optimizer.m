% STK_SELECT_OPTIMIZER is a deprecated function
%
% stk_select_optimizer is deprecated and will be removed
% from future releases of STK. Use
%
%   stk_options_get ('stk_param_estim', ...)
%   stk_options_set ('stk_param_estim', ...)
%
% instead to get/set optimizer algorithm objects.
%
% See also: stk_options_get, stk_options_set

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
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

function optim_num = stk_select_optimizer (bounds_available, display)

warning (help ('stk_select_optimizer'));

% Get current optimization algorithm objects
algo_con = stk_options_get ('stk_param_estim', 'stk_minimize_boxconstrained');
algo_unc = stk_options_get ('stk_param_estim', 'stk_minimize_unconstrained');

% Legacy: corresponding optim_num in stk <= 2.3.2
optim_num_con = get_optim_num (algo_con);
optim_num_unc = get_optim_num (algo_unc);

% Return value
if nargin > 0
    if bounds_available,
        optim_num = optim_num_con;
    else
        optim_num = optim_num_unc;
    end
else
    optim_num = [];
end

% Display status
if (nargin > 1) && display,
    
    fprintf ('Constrained optimizer for stk_param_estim: ');
    switch optim_num_con
        case 1, % octave / sqp
            fprintf ('sqp.\n');
        case 2, % Matlab / fminsearch
            fprintf ('NONE.\n');
        case 3, % Matlab / fmincon
            fprintf ('fmincon.\n');
        otherwise
            fprintf ('%s\n', class (algo_con));
    end
    
    fprintf ('Unconstrained optimizer for stk_param_estim: ');
    switch optim_num_unc
        case 1, % octave / sqp
            fprintf ('sqp.\n');
        case 2, % Matlab / fminsearch
            fprintf ('fminsearch.\n');
        otherwise
            fprintf ('%s\n', class (algo_unc));
    end
    
end

end % function


function optim_num = get_optim_num (algo)

switch class (algo)
    case 'stk_optim_octavesqp'
        optim_num = 1;
    case 'stk_optim_fminsearch'
        optim_num = 2;
    case 'stk_optim_fmincon'
        optim_num = 3;
    otherwise
        optim_num = [];
end

end % function
