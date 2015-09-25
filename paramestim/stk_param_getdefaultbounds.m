% STK_PARAM_GETDEFAULTBOUNDS
%
% FIXME: Explain what this function does, and how it is possible to define
% default bounds for user-defined covariance functions (there are two ways to do
% this...).

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec & LNE
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>
%              Remi Stroh        <remi.stroh@lne.fr>

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

function [lb, ub] = stk_param_getdefaultbounds (covariance_type, param0, xi, zi)

if isobject (param0)
    
    % param0 is an object from a class that does not implement
    % stk_param_getdefaultbounds (otherwise we wouldn't have ended up here).
    % We assume that this is a choice of the designer of the parameter class,
    % and therefore return [] without a warning.
    
    lb = [];
    ub = [];
    
elseif ~ isfloat (param0)
    
    stk_error ('Incorrect type for param0.', 'TypeMismatch');
    
else
    
    % constants
    opts = stk_options_get ('stk_param_getdefaultbounds');
    TOLVAR = opts.tolvar;
    TOLSCALE = opts.tolscale;
    
    % bounds for the variance parameter
    log_empirical_variance = log (var (double (zi)));
    if log_empirical_variance == - Inf
        logvar_lb = param0(1) - TOLVAR;
        logvar_ub = param0(1) + TOLVAR;
    else
        logvar_lb = min (log_empirical_variance, param0(1)) - TOLVAR;
        logvar_ub = max (log_empirical_variance, param0(1)) + TOLVAR;
    end
    
    dim = size (xi, 2);
    
    switch covariance_type,
        
        case {'stk_materncov_aniso', 'stk_materncov_iso'}
            
            nu_lb = min (log (0.5), param0(2));
            nu_ub = max (log (min (50, 10 * dim)), param0(2));
            
            range_mid = param0(3:end);
            range_lb  = range_mid(:) - TOLSCALE;
            range_ub  = range_mid(:) + TOLSCALE;
            
            lb = [logvar_lb; nu_lb; range_lb];
            ub = [logvar_ub; nu_ub; range_ub];
            
        case {'stk_materncov32_aniso', 'stk_materncov32_iso', ...
              'stk_materncov52_aniso', 'stk_materncov52_iso', ...
              'stk_gausscov_aniso',    'stk_gausscov_iso'}
            
            range_mid = param0(2:end);
            range_lb  = range_mid(:) - TOLSCALE;
            range_ub  = range_mid(:) + TOLSCALE;
            
            lb = [logvar_lb; range_lb];
            ub = [logvar_ub; range_ub];
            
        otherwise
            try
                % Undocumented feature: make it possible to define a
                % XXXX_getdefaultbounds function that provides parameter
                % bounds during estimation for a user-defined covariance
                % function called XXXX (in the case, where this covariance
                % has parameters type double).
                fname = [covariance_type '_getdefaultbounds'];
                [lb, ub] = feval (fname, param0, xi, zi);
            catch
                err = lasterror ();
                msg = strrep (err.message, sprintf ('\n'), sprintf ('\n|| '));
                warning(['Unable to initialize covariance parameters ' ...
                    'automatically for covariance functions of type ''%s''.'...
                    '\n\nEmpty bounds are returned.\n\nThe original error ' ...
                    'message was:\n|| %s\n'], covariance_type, msg);
                lb = [];
                ub = [];
            end
            
    end % switch
    
end % if

end % function stk_param_getdefaultbounds

