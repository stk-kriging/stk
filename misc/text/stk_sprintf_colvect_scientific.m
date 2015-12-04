% STK_SPRINTF_COLVECT_SCIENTIFIC ...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function [str, err] = stk_sprintf_colvect_scientific (x, max_width)

if isempty (x),
    str = '';
    err = 0;
    return;
end

if nargin < 2,
    max_width = 8;
end

% Turn x into a column vector
x = double (x);
x = x(:);

% Get rid of infinities
is_inf = isinf (x);
is_pos = (x > 0);
is_pinf = is_inf & is_pos;
is_minf = is_inf & (~ is_pos);
x(is_inf) = 0.0;

% Get rid of negative zeros
is_zero = (x == 0);
x(is_zero) = 0.0;

% Compute exponents
ax = abs (x);
exponent = zeros (size (x));
exponent(~is_zero) = floor (log10 (ax(~ is_zero)));

% Compute mantissae
mantissa = x .* 10 .^ (- exponent);

% Is there any negative element ?
any_negative = any (x < 0);


%--- Start with only one digit for the mantissa --------------------------------

% Nb digits for the mantissa (including the leading digit)
n1 = 1;

% Compute mantissa/exponent after rounding
[mantissa_r, exponent_r] = round_ (mantissa, exponent, n1);

% Maximal absolute exponent
maxexp = max (abs (exponent_r));

% Nb digits for the exponent
n2 = max (2, 1 + floor (log10 (maxexp)));

% Nb non-digit characters (+2 for "e+") -> no decimal separator in this case
n3 = any_negative + 2;

% Abort this is already too long
if (n1 + n2 + n3) > max_width
    str = repmat ('#', length (x), max_width);
    err = +inf;
    return;
end

% Otherwise, this is our current best solution
best_err = abs (x - mantissa_r .* 10 .^ (exponent_r));
best_n1  = 1;


%--- Try to add a decimal part -------------------------------------------------

if (any (best_err > eps * abs (x))) && ((n1 + n2 + n3 + 2) <= max_width)
    
    % We can add a decimal part, so let's do it...
    
    while (any (best_err > eps * abs (x))) && ((n1 + n2 + n3) < max_width)
        
        % Increase numer of digits for the mantissa (including the leading digit)
        n1 = n1 + 1;
        
        % Compute mantissa/exponent after rounding
        [mantissa_r, exponent_r] = round_ (mantissa, exponent, n1);
        
        % Maximal absolute exponent
        maxexp = max (abs (exponent_r));
        
        % Nb digits for the exponent
        n2 = max (2, 1 + floor (log10 (maxexp)));
        
        % Nb non-digit characters (+2 for "e+")
        %  --> "+3" for "e", "." in the mantissa and "+" in the exponent
        n3 = any_negative + 3;
        
        err = abs (x - mantissa_r .* 10 .^ (exponent_r));
        if (max (err) < max (best_err))
            best_err = err;
            best_n1 = n1;
        end
    end
end

n1 = best_n1;


%--- Produce formatted output -------------------------------------------------

% Compute mantissa/exponent after rounding
[mantissa_r, exponent_r] = round_ (mantissa, exponent, n1);

% format specifier for the mantissa
fmt1 = sprintf ('%%%d.%df', n1 + (n1 > 1) + any_negative, n1 - 1);
str1 = arrayfun (@(u)(sprintf (fmt1, u)), mantissa_r, 'UniformOutput', false);

% format specifier for the exponent
fmt2 = sprintf('e%%+0%dd', n2 + 1);
str2 = arrayfun (@(u)(sprintf (fmt2, u)), exponent_r, 'UniformOutput', false);

% merge mantissa and exponent
str = [char(str1{:}) char(str2{:})];

% fix infinities
if any (is_pinf),
    str(is_pinf, :) = [repmat(' ', 1, max_width - 3) 'Inf'];
end
if any (is_minf)
    str(is_minf, :) = [repmat(' ', 1, max_width - 4) '-Inf'];
end

% Compute the maximal error
if nargout > 1,
    err = max (abs (x - mantissa_r .* 10 .^ (exponent_r)));
end

end % function


function [mantissa_r, exponent_r] = round_ (mantissa, exponent, n1)

% Round mantissa to n1 digits (including the leading digit)
y = 10 ^ (n1 - 1);
mantissa_r = round (mantissa * y) / y;
exponent_r = exponent;

% Fix mantissa values of 10 after rounding
b = (abs (mantissa_r) == 10);
mantissa_r(b) = sign (mantissa_r(b));
exponent_r(b) = exponent_r(b) + 1;

end % function


%!shared x, s
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

%!shared x, s
%! x = [0.9; 0.91; 0.99; 0.999];
%!test s = stk_sprintf_colvect_scientific (x, 4);
%!assert (isequal(s, ['####'; '####'; '####'; '####']))
%!test s = stk_sprintf_colvect_scientific (x, 5);
%!assert (isequal(s, ['9e-01'; '9e-01'; '1e+00'; '1e+00']))
%!test s = stk_sprintf_colvect_scientific (x, 6);
%!assert (isequal(s, ['9e-01'; '9e-01'; '1e+00'; '1e+00']))
%!test s = stk_sprintf_colvect_scientific (x, 7);
%!assert (isequal(s, ['9.0e-01'; '9.1e-01'; '9.9e-01'; '1.0e+00']))
%!test s = stk_sprintf_colvect_scientific (x, 8);
%!assert (isequal(s, ['9.00e-01'; '9.10e-01'; '9.90e-01'; '9.99e-01']))

%!shared x, s
%! x = [0.9; -0.91; 0.99; 0.999];
%!test s = stk_sprintf_colvect_scientific (x, 4);
%!assert (isequal(s, ['####'; '####'; '####'; '####']))
%!test s = stk_sprintf_colvect_scientific (x, 5);
%!assert (isequal(s, ['#####'; '#####'; '#####'; '#####']))
%!test s = stk_sprintf_colvect_scientific (x, 6);
%!assert (isequal(s, [' 9e-01'; '-9e-01'; ' 1e+00'; ' 1e+00']))
%!test s = stk_sprintf_colvect_scientific (x, 7);
%!assert (isequal(s, [' 9e-01'; '-9e-01'; ' 1e+00'; ' 1e+00']))
%!test s = stk_sprintf_colvect_scientific (x, 8);
%!assert (isequal(s, [' 9.0e-01'; '-9.1e-01'; ' 9.9e-01'; ' 1.0e+00']))

%!test
%! x = [1e6; -1e10; 1e-221];
%! s = stk_sprintf_colvect_scientific(x, 10);
%! assert(isequal(s, [' 1e+006'; '-1e+010'; ' 1e-221']));
