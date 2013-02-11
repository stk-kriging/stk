% MINUS [FIXME: missing doc...]

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

function y = minus(x1, x2)

ydata = double(x1) - double(x2);

% choose if the output type
if isa(x1, 'stk_dataframe'),
    if isa(x2, 'stk_dataframe') && ~isequal(x2.vnames, vn),
        warning('Substracting stk_dataframes with different variable names.');
        output_df = false;
    else
        output_df = true;
    end
elseif isa(x2, 'stk_dataframe'),
    output_df = false;
else
    stk_error('What am I doing here ?', 'WeirdBehaviour');
end

if output_df,
    % output of type 'stk_dataframe'
    y = stk_dataframe(ydata, x1.vnames);
else
    % output of type 'double'
    y = ydata;
end

end % function minus
