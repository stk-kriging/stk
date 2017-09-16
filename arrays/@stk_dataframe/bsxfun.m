% BSXFUN [overload base function]

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec & LNE
%    Copyright (C) 2013 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Remi Stroh   <remi.stroh@lne.fr>

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

function y = bsxfun (F, x1, x2)

%---- Compute ydata -----------------------------------------------------

x1data = double (x1);
x2data = double (x2);

try
    ydata = bsxfun (F, x1data, x2data);
catch
    err = lasterror ();
    if strcmp (err.identifier, 'MATLAB:bsxfun:unsupportedBuiltin')
        % This happens in some old versions of Matlab with realpow, for
        % instance. Let's try without singleton expansion...
        ydata = feval (F, x1data, x2data);
        % TODO: manual bsxfun !!!
    else
        rethrow (err);
    end
end

%---- Choose column and row names ---------------------------------------

if isa (x1, 'stk_dataframe')
    c1 = x1.colnames;
    r1 = x1.rownames;
else
    c1 = {};
    r1 = {};
end

if isa (x2, 'stk_dataframe')
    c2 = x2.colnames;
    r2 = x2.rownames;
else
    c2 = {};
    r2 = {};
end

[nr, nc] = size (ydata);

if length (c1) == nc
    % Keep the columns names from the first dataframe (as in R)
    colnames = c1;
elseif length (c2) == nc
    colnames = c2;
else
    colnames = {};
end

if length (r1) == nr
    % Keep the columns names from the first dataframe (as in R)
    rownames = r1;
elseif length (r2) == nr
    rownames = r2;
else
    rownames = {};
end

%--- Create output ------------------------------------------------------

y = stk_dataframe (ydata, colnames, rownames);

end % function


%!shared x1, x2, data1, data2
%! x1 = rand (3, 2);  data1 = stk_dataframe (x1);
%! x2 = rand (3, 2);  data2 = stk_dataframe (x2);

%!test
%! z = bsxfun (@plus, data1, x2);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), x1 + x2))

%!test
%! z = bsxfun (@plus, x1, data2);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), x1 + x2))

%!test
%! z = bsxfun (@plus, data1, data2);
%! assert (isa (z, 'stk_dataframe') && isequal (double (z), x1 + x2))

%--- check the behaviour wrt column / row names --------------------------------

%!shared x, y
%! x = stk_dataframe (randn (2), {'x1', 'x2'}, {'a'; 'b'});
%! y = stk_dataframe (randn (2), {'y1', 'y2'}, {'c'; 'd'});

%!test z = x + y;
%! assert (isequal (z.colnames, x.colnames));
%! assert (isequal (z.rownames, x.rownames));

%!test z = y + x;
%! assert (isequal (z.colnames, y.colnames));
%! assert (isequal (z.rownames, y.rownames));

