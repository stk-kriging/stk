% PLOT_SURFMESHCONTOUR  [STK internal]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
%
%    This file recycles part of stk_plot2d.m (now deprecated):
%
%       Copyright (C) 2014 SUPELEC
%       Copyright (C) 2013 SUPELEC & Valentin Resseguier
%       Copyright (C) 2012 SUPELEC
%
%       Authors:  Julien Bect          <julien.bect@supelec.fr>
%                 Valentin Resseguier  <valentin.resseguier@gmail.com>

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

function plot_surfmeshcontour (plotfun, varargin)

[h, x, z, opts] = parse_args_ (varargin{:});

%--- Deal with various possible types for the 'z' argument ----------------

if ischar (z) || isa (z, 'function_handle')
    z = double (stk_feval (z, x));
else
    z = double (z);
end

%--- Do the actual plotting job -------------------------------------------

[xx1, xx2] = ndgrid (x);

plotfun (h, xx1, xx2, reshape (z, size (xx1)), opts{:});

% Create labels if x provides column names
c = get (x.stk_dataframe, 'colnames');
if ~ isempty (c),  stk_xlabel (c{1});  end
if length (c) > 1,  stk_ylabel (c{2});  end

% Use interpolated shading for surf and pcolor plots
if ismember (func2str (plotfun), {'surf', 'pcolor'}),
    shading ('interp');
end

end % function plot_surfmeshcontour

%#ok<*TRYNC>


function [h, x, z, opts] = parse_args_ (arg1, varargin)

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

% If the first argument can be interpreted as a handle, then it always is.

arg1_handle = false;
if isscalar (arg1) && isa (arg1, 'double'),
    try
        arg1_handle = strcmp (get (arg1, 'Type'), 'axes');
    end
end

if arg1_handle,

    if nargin < 3,
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
    end
    
    h = arg1;
    x = varargin{1};
    z = varargin{2};
    opts = varargin(3:end);
    
else

    if nargin < 2,
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
    end
    
    h = gca;
    x = arg1;
    z = varargin{1};
    opts = varargin(2:end);

end

% Then, arg1 must be an stk_factorialdesign object

if ~ isa (x, 'stk_factorialdesign')
    errmsg = 'x should be an stk_factorialdesign object.';
    stk_error (errmsg, 'TypeMismatch');
end

dim = size (x, 2);

if dim ~= 2,
    errmsg = 'Only works for two-dimensional factor spaces.';
    stk_error (errmsg, 'IncorrectArgument');
end

end % function parse_args_
