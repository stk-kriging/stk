% GET_COLUMN_INDICATOR [STK internal]

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

function b = get_column_indicator(x, s)

b = strcmp(s, x.vnames);

if ~any(b)
    if ~strcmp(s, 'a')
        errmsg = sprintf('There is no variable named %s.', idx(1).subs);
        stk_error(errmsg, 'UnknownVariable');
    else
        b = strcmp('mean', x.vnames);
        if any(b)
            warning(sprintf(['There is no variable named ''a''.\n' ...
                ' => Assuming that you''re an old STK user trying to ' ...
                'get the kriging mean.'])); %#ok<WNTAG,SPWRN>
        else
            warning(sprintf(['There is no variable named ''a''.\n' ...
                ' => Assuming that you''re an old STK user trying to ' ...
                'get the entire dataframe.'])); %#ok<WNTAG,SPWRN>
            b = true(size(b));
        end
    end
end

end % function get_column_indicator
