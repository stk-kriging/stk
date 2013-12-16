% STK_SELECT_OPTIMIZE selects an optimizer for stk_param_estim()
%
% FIXME: add documentation
%
% Returns
%   1 for Octave / sqp
%   2 for Matlab / fminsearch
%   3 for Matlab / fmincon
%

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

if nargin == 0, % invocation with no arguments (typically, in stk_init)
    
    bounds_available = true;             % in fact we don't care in stk_init...
    display = true;                      % verbose
    force_recheck = true;                % recheck which optimizer to use
    
else % invocation with at least one argument (typically, in stk_param_estim)
    
    if nargin < 2, display = false; end  % default: don't display anything
    force_recheck = false;                % don't recheck which optimizer to use
    
end

% select an appropriate optimizer
if isempty (optim_num_con) || isempty (optim_num_unc) || force_recheck,
    if isoctave,
        % We assume that the 'optim' package is installed, loaded, and
        % provides the spq() function. But we check anyway (better safe
        % than sorry) and raise an error if sqp() is nowhere to be found.
        if exist ('sqp','file') == 2,
            optim_num_con = 1;
            optim_num_unc = 1;
        else
            disp ('Function sqp not found !!!');
            error (['Please check that the optim package ', ...
                'is properly installed.']);
        end
    else
        % check if Matlab's fmincon is available
        optim_num_con = 2 + stk_is_fmincon_available();
        % use fminsearch (Nelder-Mead) for unconstrained optimization
        optim_num_unc = 2;
        % TODO: use fminunc for unconstrained optimization in Matlab
        %       if the Optimization Toolbox is available (?)
    end
    mlock();
end

% return the selected optimizer
if bounds_available,
    optim_num = optim_num_con;
else
    optim_num = optim_num_unc;
end

% display
if display,
    
    fprintf ('Constrained optimizer for stk_param_estim: ');
    switch optim_num_con
        case 1, % octave / sqp
            fprintf ('sqp.\n');
        case 2, % Matlab / fminsearch
            fprintf ('NONE.\n');
            warning (['Function fmincon not found, ', ...
                'falling back on fminsearch.']); %#ok<WNTAG>
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
