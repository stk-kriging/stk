% PLOT_SURFMESHCONTOUR  [STK internal]

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
%    Copyright (C) 2013 Valentin Resseguier
%    Copyright (C) 2012-2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
%             Valentin Resseguier  <valentin.resseguier@gmail.com>

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

function h_plot = plot_surfmeshcontour (plotfun, varargin)

[h_axes, x, z, opts] = parse_args_ (varargin{:});

%--- Deal with various possible types for the 'z' argument ----------------

if ischar (z) || isa (z, 'function_handle')
    z = double (stk_feval (z, x));
else
    z = double (z);
end

%--- Do the actual plotting job -------------------------------------------

[xx1, xx2] = ndgrid (x);

h_plot = call_plotfun (plotfun, h_axes, ...
    xx1, xx2, reshape (z, size (xx1)), opts{:});

% Create labels if x provides column names
c = get (x.stk_dataframe, 'colnames');
if ~ isempty (c)
    stk_xlabel (h_axes, c{1}, 'interpreter', 'none');  % CG#10
end
if length (c) > 1
    stk_ylabel (h_axes, c{2}, 'interpreter', 'none');  % CG#10
end

% Use interpolated shading for surf and pcolor plots
if ismember (func2str (plotfun), {'surf', 'pcolor'})
    shading (h_axes, 'interp');
end

end % function

%#ok<*TRYNC>


function [h_axes, x, z, opts] = parse_args_ (varargin)

%--- Formal grammar for the list of arguments -----------------------------
%
% Terminal symbols
%
%    h = a handle to an axes object
%    x = stk_factorial_design object
%    z = ordinate argument
%
% Derivation rules
%
%	<arg_list>          ::= <arg_list_0> | h <arg_list_0>
%   <arg_list_0>        ::= x z <optional_arguments>

% Extract axis handle (if it is present)
[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin < 2
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

x = varargin{1};
z = varargin{2};
opts = varargin(3:end);

% Then, x must be an stk_factorialdesign object
if ~ isa (x, 'stk_factorialdesign')
    stk_error (['The first input argument should be a handle to existing' ...
        'axes or and stk_factorialdesign object.'], 'TypeMismatch');
end

dim = size (x, 2);

if dim ~= 2
    errmsg = 'Only works for two-dimensional factor spaces.';
    stk_error (errmsg, 'InvalidArgument');
end

end % function


function h_plot = call_plotfun (plotfun, h_axes, x, y, z, varargin)

% In Octave 3.6.4, pcolor supports neither the axis handle argument nor
% the optional parameter/value arguments. This function has been created to
% overcome this and other similar issues.

try
    
    % When the full 'modern' syntax is supported, the result is usually better,
    % in particular when options are provided. Let's try that first.
    
    if strcmp (func2str (plotfun), 'contour')
        [ignd, h_plot] = contour ...
            (h_axes, x, y, z, varargin{:});  %#ok<ASGLU> CG#07
    else
        h_plot = plotfun (h_axes, x, y, z, varargin{:});
    end
    
catch  %#ok<CTCH>
    
    % Do we have an additional numeric argument ?
    if isempty (varargin)
        numarg = {};
        opts = {};
    else
        if ischar (varargin{1})
            numarg = {};
            opts = varargin;
        else
            numarg = varargin(1);
            opts = varargin(2:end);
        end
    end
    
    % Select the axes to draw on
    h1 = gca ();  axes (h_axes);
    
    try
        
        if strcmp (func2str (plotfun), 'contour')
            [ignd, h_plot] = contour (x, y, z, numarg{:});  %#ok<ASGLU> CG#07
        else
            h_plot = plotfun (x, y, z, numarg{:});
        end
        
        if ~ isempty (opts)
            set (h_plot, opts{:});
        end
        
        axes (h1);
        
    catch  %#ok<CTCH>
        axes (h1);
        rethrow (lasterror ());  %#ok<LERR>
    end
    
end % try_catch

end % function
