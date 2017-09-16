% PLOT [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

function h_plot = plot (varargin)

% Parse the list of input arguments
[h_axes, plot_elem, keyval_pairs] = parse_args_ (varargin{:});

% Read hold state
b = ishold ();

% Plot all
n = length (plot_elem);
h_plot = [];
for i = 1:n
    p = plot_elem(i);
    hh = plot_ (h_axes, p.x, p.z, p.S, keyval_pairs{:});
    h_plot = [h_plot; hh];  %#ok<AGROW>
    if (i == 1) && (n > 1),  hold on;  end
end

% Restore hold state
if (~ b) && (n > 1),  hold off;  end

end % function


function h = plot_ (h_axes, x, z, S, varargin)

%--- Handle stk_dataframe inputs ------------------------------------------

if isa (x, 'stk_dataframe')
    xlab = x.colnames;
    x = double (x);
else
    xlab = {};
end

if isa (z, 'stk_dataframe')
    zlab = z.colnames;
    z = double (z);
else
    zlab = {};
end

%--- Deal with various forms for x and z ----------------------------------

if isempty (x)  % Special: x not provided
    
    % Tolerate row vector for z
    if isrow (z),  z = z';  end
    
    % Create a default x
    x = (1:(size (z, 1)))';
    
else  % General case
    
    % Tolerate row vector for x
    if isrow (x),  x = x';  end
    
    % Number of points
    n = size (x, 1);
    
    % Tolerate row vector for z
    if isequal (size (z), [1 n]),  z = z';  end
    
end

%--- Plot and set labels --------------------------------------------------

if isempty (S)
    h = plot (h_axes, x, z, varargin{:});
else
    h = plot (h_axes, x, z, S, varargin{:});
end

if ~ isempty (xlab)
    if size (x, 2) == 1
        stk_xlabel (xlab{1}, 'interpreter', 'none');  % CG#10
    end
    % Note: in the case where x has several columns (and z also) we could
    % create more elaborate legends, e.g., "Zj versus Xj". Another time.
end

if ~ isempty (zlab)
    if size (z, 2) == 1
        stk_ylabel (zlab{1}, 'interpreter', 'none');  % CG#10
    else
        legend (zlab{:});
    end
end

end % function

%#ok<*SPWRN,*TRYNC>


function [h_axes, plot_elem, keyval_pairs] = parse_args_ (varargin)

% Plot is highly polymorphic, making the task of parsing input arguments a
% rather lengthy and painful one...

%--- Formal grammar for the list of arguments -----------------------------
%
% Terminal symbols
%
%    h = a handle to an axes object
%    x = abscissa argument
%    z = ordinate argument
%    S = symbol/color/line string argument
%    k = key in a key-val pair
%    v = value in a key-val pair
%
% Derivation rules
%
%	<arg_list>          ::= <arg_list_0> | h <arg_list_0>
%   <arg_list_0>        ::= <plot_elem_list> <keyval_pairs>
%   <keyval_pairs>      ::= k v | <keyval_pairs> k v
%   <plot_elem_list>    ::= <plot_elem_single> | <plot_elem_several>
%	<plot_elem_several> ::= <plot_elem> | <plot_elem_several> <plot_elem>
%   <plot_elem_single>  ::= <plot_elem> | <special_plot_elem>
%	<plot_elem>         ::= x z | x z S
%   <special_plot_elem> ::= z | z S

% Extract axis handle (if it is present)
[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

if n_argin == 0
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

% Extract first element from the list of arguments
arg1 = varargin{1};
varargin(1) = [];

% Then, arg1 *must* be a "numeric" argument
if ischar (arg1)
    stk_error ('Syntax error. Unexpected string argument.', 'TypeMismatch');
end

% Then, process remaining arguments recursively
if isempty (varargin)
    
    % Special case: x has been omitted, and there are no additional args
    plot_elem = struct ('x', [], 'z', {arg1}, 'S', []);
    keyval_pairs = {};
    
elseif ischar (varargin{1})
    
    % Special case: x has been omitted, and there *are* additional args
    if mod (length (varargin), 2)
        S = [];
        keyval_pairs = parse_keyval_ (varargin);
    else
        S = varargin{1};
        keyval_pairs = parse_keyval_ (varargin{2:end});
    end
    plot_elem = struct ('x', [], 'z', {arg1}, 'S', {S});
    
else
    
    % General case
    [plot_elem, keyval_pairs] = parse_args__ (arg1, varargin{:});
    
end

end % function


function [plot_elem, keyval_pairs] = parse_args__ (x, z, varargin)

if ischar (x) || ischar (z)
    display (x);  display (z);
    stk_error (['Syntax error. At this point, we were expecting ' ...
        'another numeric (x, z) pair.'], 'SyntaxError');
end

if isempty (varargin)
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', []);
    keyval_pairs = {};
    
elseif ~ ischar (varargin{1})  % expect another (x, z) pair after this one
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', []);
    [plot_elem_, keyval_pairs] = parse_args__ (varargin{:});
    plot_elem = [plot_elem plot_elem_];
    
elseif length (varargin) == 1  % S
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', varargin(1));
    keyval_pairs = {};
    
elseif ischar (varargin{2})  % S, key, val, ...
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', varargin(1));
    keyval_pairs = parse_keyval_ (varargin{2:end});
    
elseif length (varargin) == 2  % key, val
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', []);
    keyval_pairs = varargin;
    
elseif ~ ischar (varargin{3})  % S, x, z, ...
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', varargin(1));
    [plot_elem_, keyval_pairs] = parse_args__ (varargin{2:end});
    plot_elem = [plot_elem plot_elem_];
    
else  % key, val, key, val, ...
    
    plot_elem = struct ('x', {x}, 'z', {z}, 'S', []);
    keyval_pairs = parse_keyval_ (varargin{:});
    
end

end % function

function keyval_pairs = parse_keyval_ (key, val, varargin)

if nargin == 0
    
    keyval_pairs = {};
    
elseif nargin == 1
    
    errmsg = 'Syntax error. Incomplete key-value pair';
    stk_error (errmsg, 'NotEnoughInputArgs');
    
elseif ~ ischar (key)
    
    display (key);
    stk_error (['Syntax error. At his point, we were expecting a ' ...
        'key-value pair, but key is not a string.'], 'TypeMismatch');
    
else
    
    keyval_pairs = [{key, val} parse_keyval_(varargin{:})];
    
end

end % function


%!test % plot with x as a vector and z as a (univariate) dataframe
%! x = linspace(0, 2*pi, 30)';
%! z = stk_dataframe(sin(x));
%! figure; plot(x, z); close(gcf);

%!test % plot with x as a vector and z as a (multivariate) dataframe
%! x = linspace(0, 2*pi, 30)';
%! z = stk_dataframe([sin(x) cos(x)], {'sin' 'cos'});
%! figure; plot(x, z); close(gcf);

%!test % plot with x as a dataframe and z as a vector
%! x = stk_dataframe(linspace(0, 2*pi, 30)');
%! z = sin(double(x));
%! figure; plot(x, z); close(gcf);
