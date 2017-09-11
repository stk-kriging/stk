% DISP [overload base function]
%
% Example:
%    format short
%    x = [1 1e6 rand; 10 -1e10 rand; 100 1e-22 rand];
%    disp (stk_dataframe (x))

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function disp (x, verbosity, prefix, data_col_width)

if (nargin < 2) || (isempty (verbosity))
    verbosity = stk_options_get ('stk_dataframe', 'disp_format');
end

if (nargin < 3) || (isempty (prefix))
    prefix = ' ';
end

if (nargin < 4) || (isempty (data_col_width))
    data_col_width = [];
end

s = stk_sprintf (x, verbosity, data_col_width);
disp ([repmat(prefix, size(s, 1), 1) s]);

end % function


%!shared x, fmt
%! fmt = stk_disp_getformat ();
%! x = stk_dataframe (rand (3, 2));

%!test format rat;    disp (x);
%!test format long;   disp (x);
%!test format short;  disp (x);  format (fmt);

%!test disp (stk_dataframe (zeros (0, 1)))
%!test disp (stk_dataframe (zeros (0, 2)))
