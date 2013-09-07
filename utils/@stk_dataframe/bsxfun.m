% BSXFUN [overloaded base function]

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

function y = bsxfun(F, x1, x2)

x1data = double (x1);
x2data = double (x2);

try
    ydata = bsxfun(F, x1data, x2data);
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

% choose if the output type
if isa(x1, 'stk_dataframe'),
    y = stk_dataframe(ydata, x1.colnames);
else
    y = ydata;
end

end % function bsxfun

%!shared x1 x2 data1 data2
%! x1 = rand(3, 2);  data1 = stk_dataframe(x1);
%! x2 = rand(3, 2);  data2 = stk_dataframe(x2);

%!test
%! z = bsxfun(@plus, data1, x2);
%! assert( isa(z, 'stk_dataframe') && isequal(double(z), x1 + x2))

%!test
%! z = bsxfun(@plus, x1, data2);
%! assert( isa(z, 'double') && isequal(z, x1 + x2))

%!test
%! z = bsxfun(@plus, data1, data2);
%! assert( isa(z, 'stk_dataframe') && isequal(double(z), x1 + x2))

