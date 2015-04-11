% BSXFUN [overload base function]

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

%---- Choose column names -----------------------------------------------

if isa (x1, 'stk_dataframe'),
    c1 = x1.colnames;
else
    c1 = {};
end

if isa (x2, 'stk_dataframe'),
    c2 = x2.colnames;
else
    c2 = {};
end

if isempty (c1)
    colnames = c2;
elseif isempty (c2)
    colnames = c1;
else
    if (~ isequal (size (c1), size (c2))) || (any (~ strcmp (c1, c2)))
        warning ('STK:bsxfun:IncompatibleColumnNames', ...
            'Incompatible column names.');  colnames = {};
    else
        colnames = c1;
    end
end

%--- Create output ------------------------------------------------------

y = stk_dataframe (ydata, colnames);

end % function bsxfun


% DESIGN NOTES
%
% Starting from STK 2.2.0, the result of bsxfun is ALWAYS an
% stk_dataframe object, and has column names iff
%  * either one of the two arguments doesn't have columns names
%  * or the columns names of both arguments agree.
%
% With this design choice, we ensure that if the underlying operation F
% is commutative on double-precision arrays, then it stays commutative
% on stk_dataframe objects.


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

