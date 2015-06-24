% STK_SELECT_OPTIMIZER selects an optimizer for stk_param_estim()
%
% CALL: OPTIM_NUM = stk_select_optimizer (BOUNDS_AVAILABLE)
%
%   returns a number that indicates which optimizer STK should use for
%   box-constrained (if BOUNDS_AVAILABLE is true or absent) or unconstrained
%   optimization in its parameter estimation procedure. The result OPTIM_NUM is
%   equal to 1 for Octave/sqp, 2 for Matlab/fminsearch, or 3 for Matlab/fmincon.

% Copyright Notice
%
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

persistent optim_num_con optim_num_unc

% Invocation with no arguments (setup) =>  recheck which optimizer to use
force_recheck = (nargin == 0);

% Select an appropriate optimizer
if isempty (optim_num_con) || isempty (optim_num_unc) || force_recheck,
    
    if isoctave,
        % Use sqp for both unconstrained and box-constrained optimization
        optim_num_con = 1;
        optim_num_unc = 1;
    else
        % check if Matlab's fmincon is available
        optim_num_con = 2 + stk_optim_hasfmincon ();
        % use fminsearch (Nelder-Mead) for unconstrained optimization
        optim_num_unc = 2;
        % TODO: use fminunc for unconstrained optimization in Matlab
        %       if the Optimization Toolbox is available (?)
    end
    
    mlock;
    
    % In Matlab, warn if fmincon is not present
    if (~ isoctave) && (optim_num_con == 2)
        warning (['Function fmincon not found, ', ...
            'falling back on fminsearch.']); %#ok<WNTAG>
    end
    
end

% Return the selected optimizer
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
            error ('Unexpected value for optim_num_con');
    end
    
    fprintf ('Unconstrained optimizer for stk_param_estim: ');
    switch optim_num_unc
        case 1, % octave / sqp
            fprintf ('sqp.\n');
        case 2, % Matlab / fminsearch
            fprintf ('fminsearch.\n');
        otherwise
            error ('Unexpected value for optim_num_unc');
    end
    
end

end % function stk_select_optimizer
