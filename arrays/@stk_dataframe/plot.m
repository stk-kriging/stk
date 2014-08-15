% PLOT [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function plot (arg1, varargin)

%--- Plot is highly polymorphic... which case are we dealing with ? -------

% Extract "numeric" arguments from varargin
%    (note: axes handles ARE numeric argument... WTF...)

T = @(a)(isnumeric (a) || isa (a, 'stk_dataframe'));

if ~ T (arg1)    
    stk_error (['The first argument to stk_dataframe/plot must be ' ...
        'numeric or an stk_dataframe object.'], 'TypeMismatch');
end
k = 1;  % at this point, we have at least one "numeric" argument
if (nargin > 1) && (~ ischar (varargin{1}))
    arg2 = varargin{1};  varargin(1) = [];
    if ~ T (arg2)
        stk_error (['The second argument to stk_dataframe/plot must be' ...
            ' numeric or an stk_dataframe object.'], 'TypeMismatch');
    end
    k = 2;  % at this point, we have at least two "numeric" arguments
    if (nargin > 2) && (~ ischar (varargin{1}))
        arg3 = varargin{1};  varargin(1) = [];
        if ~ T (arg3)
            stk_error (['The third argument to stk_dataframe/plot ' ...
                'must be numeric or an stk_dataframe object.'], ...
                'TypeMismatch');
        end
        k = 3;
    end
    if (nargin > 3) && (~ ischar (varargin{1}))
        stk_error (['Syntax error, expecting a char argument at the ' ...
            'fourth position.'], 'TypeMismatch');
    end
end 

% Now figure out which case we are dealing with

switch k
    case 1
        z = arg1;
        h = gca;                 % default: current axes
        x = (1:(size (z, 1)))';  % default: x = 1 ... n
    case 2
        arg1_handle = false;
        if isnumeric (arg1) && isscalar (arg1)  % perhaps a handle ?
            try  arg1_handle = strcmp (get (arg1, 'Type'), 'axes');  end
        end
        if arg1_handle,
            h = arg1;
            z = arg2;
            x = (1:(size (z, 1)))';  % default: x = 1 ... n
        else
            x = arg1;
            z = arg2;
            h = gca;
        end
    case 3
        try
            assert (strcmp (get (arg1, 'Type'), 'axes'));
        catch
            stk_error (['When calling stk_dataframe/plot with three ' ...
                'numeric arguments, the first one must be a handle to ' ...
                'an axes object handle.'], 'IncorrectArgument');
        end
        h = arg1;
        x = arg2;
        z = arg3;
end

%--- Handle stk_dataframe inputs ------------------------------------------

if isa (x, 'stk_dataframe'),
    xlab = x.colnames;
    x = double (x);    
else
    xlab = {};
end

if isa (z, 'stk_dataframe'),
    zlab = z.colnames;
    z = double (z);    
else
    zlab = {};
end

%--- Dimension of x and z ? -----------------------------------------------

% Tolerate row vector for x
if isrow (x),  x = x';  end

% Handle deprecated syntax where x has several columns
if size (x, 2) > 1
    warning ('STK:plot:Deprecated', sprintf (['DEPRECATED SYNTAX\n' ...
        'stk_dataframe/plot (x, ...) not supported anymore for ' ...
        'stk_dataframe objects with more than one column.']));
    plot (x.data(:, 1), x.data(:, 2), varargin{:});
    return;
end

% Number of points
n = size (x, 1);

% Tolerate row vector for z
if isequal (size (z), [1 n]),  z = z';  end
        
%--- Plot and set labels --------------------------------------------------

plot (h, x, z, varargin{:});

if ~ isempty (xlab),
    stk_xlabel (xlab);
end

if ~ isempty (zlab)
    if size (z, 2) == 1,
        stk_ylabel (zlab{1});
    else
        legend (zlab{:});
    end
end

end % function plot

%#ok<*SPWRN,*TRYNC>


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
