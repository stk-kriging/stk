% STK_OPTIONS_SET sets the value of one or all STK options

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%    Copyright (C) 2013 SUPELEC
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

function opts = stk_options_set (varargin)

persistent options

if isempty (options)
    options = init_options ();
    mlock;
end

switch nargin
    
    case 0  % nothing to do, just return the output
        
    case 1  % reset
        if (ischar (varargin{1})) && strcmp (varargin{1}, 'default')
            options = init_options ();
        else
            stk_error ('Syntax error', 'SyntaxError');
        end
        
    case 2
        switch varargin{1}
            
            case 'stk_sf_matern'
                % TODO: Remove this warning in STK 3.x
                warning (sprintf([ ...
                    'stk_sf_matern and the corresponding options have been ' ...
                    'deprecated.\n\nPlease use stk_rbf_matern instead.\n']));
                options.stk_rbf_matern = varargin{2};
                
            otherwise
                options.(varargin{1}) = varargin{2};
        end
        
    case 3
        switch varargin{1}
            
            case 'stk_param_estim'
                if strcmp (varargin{2}, 'optim_display_level')
                    % TODO: Remove this warning in STK 3.x
                    warning (sprintf ([ ...
                        'Options stk_param_estim.optim_display_level has ' ...
                        'been removed.\n\nDisplay options for optimization ' ...
                        'algorithms can be set through the properties of ' ...
                        'the algorithm objects instead.\n']));
                else
                    options.stk_param_estim.(varargin{2}) = varargin{3};
                end
                
            case 'stk_sf_matern'
                % TODO: Remove this warning in STK 3.x
                warning (sprintf([ ...
                    'stk_sf_matern and the corresponding options have been ' ...
                    'deprecated.\n\nPlease use stk_rbf_matern instead.\n']));
                options.stk_rbf_matern.(varargin{2}) = varargin{3};
                
            otherwise
                options.(varargin{1}).(varargin{2}) = varargin{3};
        end
        
    otherwise
        stk_error ('Incorrect number of input arguments.', 'SyntaxError');
        
end

if nargout > 0
    opts = options;
end

end % function

%#ok<*CTCH,*SPWRN>


function opts = init_options ()

opts = struct ();

opts.stk_rbf_matern.min_size_for_parallelization = 1e5;
opts.stk_rbf_matern.min_block_size = 1e3;

opts.stk_dataframe.disp_format = 'basic'; % 'basic' or 'verbose'
opts.stk_dataframe.disp_spstr = '    ';
opts.stk_dataframe.openvar_warndlg = true;

opts.stk_param_getdefaultbounds.tolvar = 5.0;
opts.stk_param_getdefaultbounds.tolscale = 5.0;

opts.stk_figure.properties = {'InvertHardcopy', 'off', 'Color', [1 1 1]};
opts.stk_xlabel.properties = {'FontSize', 10, 'Color', [0.2 0 1]};
opts.stk_ylabel.properties = opts.stk_xlabel.properties;
opts.stk_zlabel.properties = opts.stk_xlabel.properties;
opts.stk_title.properties = {'FontSize', 10, 'FontWeight', 'bold'};
opts.stk_axes.properties = {'FontSize', 8};

% Select optimizer for stk_param_estim
if exist ('OCTAVE_VERSION', 'builtin') == 5
    % In Octave we use sqp (which is always available) in both cases
    opts.stk_param_estim.minimize_box = stk_optim_octavesqp ();
    opts.stk_param_estim.minimize_unc = stk_optim_octavesqp ();
else
    A_fminsearch = stk_optim_fminsearch ();
    try
        % See if the Mathworks' Optimization toolbox is installed
        opts.stk_param_estim.minimize_box = stk_optim_fmincon ();
        opts.stk_param_estim.minimize_unc = A_fminsearch;  % FIXME: use fminunc !
        check_both (opts.stk_param_estim);
    catch
        try
            % See sqp can be used with MOSEK's quadprog
            %   (or any other compatible replacement for quadprog)
            A = stk_optim_octavesqp (struct ('qp_solver', 'quadprog'));
            opts.stk_param_estim.minimize_box = A;
            opts.stk_param_estim.minimize_unc = A;
            check_both (opts.stk_param_estim);
        catch
            opts.stk_param_estim.minimize_box = A_fminsearch;
            opts.stk_param_estim.minimize_unc = A_fminsearch;
        end
    end
end

end % function


function check_both (opts)

assert (stk_optim_testmin_box (opts.minimize_box));
assert (stk_optim_testmin_unc (opts.minimize_unc));

end % function
