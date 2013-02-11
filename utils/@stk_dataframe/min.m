% MIN computes the minimum of each variable in a dataframe

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

function z = min(x, y, dim)
stk_narginchk(1, 3);

% process argument 'x'
if isa(x, 'stk_dataframe'),
    xdata = x.data;
    xvarnames = x.vnames;
else
    xdata = x;
    xvarnames = {};
end

% process argument 'y'
if nargin < 2,
    ydata = [];
    yvarnames = {};
elseif isa(y, 'stk_dataframe');
    ydata = y.data;
    yvarnames = y.vnames;
else
    ydata = y;
    yvarnames = {};
end

% if both x and y are dataframes, they should have the same variables
if isempty(xvarnames) || isempty(yvarnames)
    output_df = true;
    vnames = {xvarnames{:} yvarnames{:}};
else
    output_df = isequal(xvarnames, yvarnames);
    vnames = xvarnames;
    if ~output_df,
        warning('Processing stk_dataframes with different variable names.');
    end
end

% third argument must be 1
if (nargin == 3) && (dim ~= 1),
    errmsg = 'min() always acts columnwise on stk_dataframe objects.';
    stk_error(errmsg, 'IncorrectArgument');
end

z = min(xdata, ydata);
if output_df,
    z = stk_dataframe(z, vnames);
end
    
end % function min


%!shared x1 df1 x2 df2 x3 df3 z
%! x1 = rand(10, 3);  df1 = stk_dataframe(x1, {'a', 'b', 'c'});
%! x2 = rand(10, 3);  df2 = stk_dataframe(x2, {'a', 'b', 'c'});
%! x3 = rand(10, 3);  df3 = stk_dataframe(x3, {'f', 'g', 'h'});

%!test z = min(df1, df2);
%!assert (isa(z, 'stk_dataframe') && isequal(double(z), min(x1, x2)));

%!test z = min(df1, x2);
%!assert (isa(z, 'stk_dataframe') && isequal(double(z), min(x1, x2)));

%!test z = min(x1, df2);
%!assert (isa(z, 'stk_dataframe') && isequal(double(z), min(x1, x2)));

%!test warning off; z = min(df1, df3); warning on;
%!assert (~isa(z, 'stk_dataframe') && isequal(double(z), min(x1, x3)));
