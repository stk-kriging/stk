% PLOT [overloaded base function]

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

function plot (x, varargin)

if ~ strcmp (x, 'stk_dataframe'),
    if isa (x, 'stk_dataframe')
        x = stk_dataframe (double (x), get (x, 'colnames'));
    else
        x = stk_dataframe (double (x));
    end
end

if (nargin > 1) && (~ ischar (varargin{1}))
    if size(x, 2) > 1,
        stk_error('Incorrect size for argument x.', 'IncorrectSize');
    else
        x = horzcat (x, varargin{1});
        opts_pos = 2;
    end
else
    if size (x, 2) > 2,
        warning ('Plotting the first two columns only.'); %#ok<WNTAG>
        % TODO: implement scatter plot matrices
    end
    opts_pos = 1;
end

if nargin > opts_pos,
    opts = varargin(opts_pos:end);
else
    opts = {};
end

xx = double (x);
yy = xx(:, 2:end);
xx = xx(:, 1);

nb_outputs = size (yy, 2);

colnames = get (x, 'colnames');

if ~ isempty (colnames)
    xlab = colnames{1};
    ylab = colnames(2:end);
else
    xlab = '';
    ylab = repmat ({''}, 1, nb_outputs);
end

plot (xx, yy, opts{:});

xlabel (xlab, 'FontWeight', 'bold');

if nb_outputs == 1,
    ylabel (ylab{1}, 'FontWeight', 'bold');
elseif ~ isempty (ylab)
    legend (ylab{:});
end

end % function plot

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

%!test
%! x = stk_dataframe (rand (10, 2));
%! figure; plot (x); close (gcf);

%!test % same thing, but with more than two columns
%! x = stk_dataframe (rand (10, 4));
%! figure; plot (x, 'k.'); close (gcf);

%!error % the first argument should have one and only one column
%! x = stk_dataframe(rand(10, 2));
%! z = stk_dataframe(rand(10, 1));
%! plot(x, z);
