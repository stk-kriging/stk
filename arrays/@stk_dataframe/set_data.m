% @STK_DATAFRAME/SET_DATA [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function x = set_data (x, data)

[n1, d1] = size (x.data);
[n2, d2] = size (data);
x.data = data;

if (n1 ~= n2) && ~ isempty (x.rownames)
    if n2 > n1
        % silently add rows without a name
        x.rownames = [x.rownames; repmat({''}, n2 - n1, 1)];
    else
        % delete superfluous row names and emit a warning
        x.rownames = x.rownames(1:n2);
        warning ('Some row names have been deleted.');
    end
end

if (d1 ~= d2) && ~ isempty (x.colnames)
    if d2 > d1
        % silently add columns without a name
        x.colnames = [x.colnames; repmat({''}, 1, d2 - d1)];
    else
        % delete superfluous column names and emit a warning
        x.colnames = x.colnames(1:d2);
        warning ('Some column names have been deleted.');
    end
end

end % function
