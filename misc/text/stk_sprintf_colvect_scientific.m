% STK_SPRINTF_COLVECT_SCIENTIFIC ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function [str, err] = stk_sprintf_colvect_scientific(x, max_width)

if nargin < 2,
    max_width = 10;
end

% turn x into a column vector
x = double(x);
x = x(:);

% get rid of negative zeros
b = (x == 0); 
x(b) = +0.0;

% compute exponents
ax = abs(x);
exponent = zeros(size(x));
exponent(~b) = floor(log10(ax(~b)));

% compute mantissae
mantissa = x .* 10.^(-exponent);

% maximal exponent
maxexp = max(exponent);

% is there any negative element ?
any_negative = any(x < 0);

% Start with only one digit for the mantissa (no comma, then)
n1 = 1;                                 % nb digits for the mantissa
n2 = max(2, 1 + floor(log10(maxexp)));  % nb digits for the exponent
n3 = any_negative + 2;                  % nb non-digit characters (+2 for "e+")

% Abort this is already too long
if (n1 + n2 + n3) > max_width
    str = repmat('#', length(x), max_width);
    err = +inf;
    return;
end

% Otherwise, this is our current best solution
am = abs(mantissa);
best_err = max(am - floor(am)); % maximal error on the matissa
best_n1  = 1;

% Should we add a decimal part ?
if (best_err > eps) && ((n1 + n2 + n3 + 2) <= max_width)
    % We can add a decimal part, so let's do it...
    while (best_err > eps) && ((n1 + n2 + n3) < max_width)
        n1 = n1 + 1;
        n3 = any_negative + 3;
        % "+3" for "e", "." in the mantissa and "+" in the exponent      
        c = 10^(1 - n1);
        mm = round(am ./ c) .* c;
        err = max(abs(am - mm));
        if err < best_err - 0.5 * c
            best_err = err;
            best_n1 = n1;
        end
    end
end
n1 = best_n1;

% format specifier for the mantissa
fmt1 = sprintf('%%%d.%df', n1 + (n1 > 1) + any_negative, n1 - 1);
str1 = arrayfun(@(u)(sprintf(fmt1, u)), mantissa, 'UniformOutput', false);

% format specifier for the exponent
fmt2 = sprintf('e%%+0%dd', n2 + 1);
str2 = arrayfun(@(u)(sprintf(fmt2, u)), exponent, 'UniformOutput', false);

str = [char(str1{:}) char(str2{:})];

% Compute the maximal error
if nargout > 1,
    c = 10^(1 - n1);
    rounded_mantissa = round(mantissa / c) * c;
    err_mantissa = abs(rounded_mantissa - mantissa);
    err = max(err_mantissa .* 10.^(exponent));
end
    
end % function stk_sprintf_colvect_scientific


%!shared x s
%! x = [1.2; -34567];
%!test s = stk_sprintf_colvect_scientific(x, 1);
%!assert (isequal(s, ['#'; '#']))
%!test s = stk_sprintf_colvect_scientific(x, 3);
%!assert (isequal(s, ['###'; '###']))
%!test s = stk_sprintf_colvect_scientific(x, 5);
%!assert (isequal(s, ['#####'; '#####']))
%!test s = stk_sprintf_colvect_scientific(x, 6);
%!assert (isequal(s, [' 1e+00'; '-3e+04']))
%!test s = stk_sprintf_colvect_scientific(x, 7);
%!assert (isequal(s, [' 1e+00'; '-3e+04']))
%!test s = stk_sprintf_colvect_scientific(x, 8);
%!assert (isequal(s, [' 1.2e+00'; '-3.5e+04']))
%!test s = stk_sprintf_colvect_scientific(x, 9);
%!assert (isequal(s, [' 1.20e+00'; '-3.46e+04']))
%!test s = stk_sprintf_colvect_scientific(x, 10);
%!assert (isequal(s, [' 1.200e+00'; '-3.457e+04']))
%!test s = stk_sprintf_colvect_scientific(x, 11);
%!assert (isequal(s, [' 1.2000e+00'; '-3.4567e+04']))
%!test s = stk_sprintf_colvect_scientific(x, 12);
%!assert (isequal(s, [' 1.2000e+00'; '-3.4567e+04']))
