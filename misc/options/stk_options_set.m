% STK_OPTIONS_SET sets the value of one or all STK options.

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%    Copyright (C) 2013 SUPELEC
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

function opts = stk_options_set (varargin)

persistent options

if isempty (options)
    options = init_options ();
    mlock;
end

switch nargin
    
    case 0, % nothing to do, just return the output
        
    case 1, % reset
        if (ischar (varargin{1})) && strcmp (varargin{1}, 'default')
            options = init_options ();
        else
            stk_error ('Syntax error', 'SyntaxError');
        end
        
    case 2,
        options.(varargin{1}) = varargin{2};
        
    case 3,
        options.(varargin{1}).(varargin{2}) = varargin{3};
        
    otherwise
        stk_error ('Incorrect number of input arguments.', 'SyntaxError');
        
end

opts = options;

end % function stk_options_set

%#ok<*CTCH>
 
 
function opts = init_options ()

opts = struct ();

opts.stk_sf_matern.min_size_for_parallelization = 1e5;
opts.stk_sf_matern.min_block_size = 1e3;

opts.stk_dataframe.disp_format = 'basic'; % 'basic' or 'verbose'
opts.stk_dataframe.disp_spstr = '    ';

opts.stk_param_getdefaultbounds.tolvar = 5.0;
opts.stk_param_getdefaultbounds.tolscale = 5.0;

opts.stk_param_estim.optim_display_level = 'off';

opts.stk_figure.properties = {'InvertHardcopy', 'off', 'Color', [1 1 1]};
opts.stk_xlabel.properties = {'FontSize', 10, 'Color', [0.2 0 1]};
opts.stk_ylabel.properties = opts.stk_xlabel.properties;
opts.stk_title.properties = {'FontSize', 10, 'FontWeight', 'bold'};
opts.stk_axes.properties = {'FontSize', 8};

if isoctave
    opts.stk_param_estim.stk_minimize_boxconstrained = stk_optim_octavesqp ();
    opts.stk_param_estim.stk_minimize_unconstrained = stk_optim_octavesqp ();
else
    try
        opts.stk_param_estim.stk_minimize_boxconstrained = stk_optim_fmincon ();
    catch
        opts.stk_param_estim.stk_minimize_boxconstrained = stk_optim_fminsearch ();
    end
    opts.stk_param_estim.stk_minimize_unconstrained = stk_optim_fminsearch ();
end

end % function init_options
