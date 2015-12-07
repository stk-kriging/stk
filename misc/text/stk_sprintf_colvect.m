% STK_SPRINTF_COLVECT ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function str = stk_sprintf_colvect (x, max_width)

if nargin < 2,
    max_width = 8;
end
    
% Try fixed-point notation first.
[str, err_fp] = stk_sprintf_colvect_fixedpoint (x, max_width);

if err_fp > 0,
    % Accept fixed-point notation if the error is zero,
    % try scientific notation otherwise.
    [str_sc, err_sc] = stk_sprintf_colvect_scientific (x, max_width);
    if err_sc < err_fp,
        % Choose scientific notation if it's better than fixed-point
        str = str_sc;
    end
end

end % function


%!shared s
%!test s = stk_sprintf_colvect ([1 1e1], 6);
%!assert (isequal (s, [' 1'; '10']))
%!test s = stk_sprintf_colvect ([1 1e3], 6);
%!assert (isequal (s, ['   1'; '1000']))
%!test s = stk_sprintf_colvect ([1 1e5], 6);
%!assert (isequal (s, ['     1'; '100000']))
%!test s = stk_sprintf_colvect ([1 1e6], 6);
%!assert (isequal (s, ['1e+00'; '1e+06']))
