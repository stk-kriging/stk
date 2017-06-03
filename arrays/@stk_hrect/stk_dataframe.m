% @STK_HRECT/STK_DATAFRAME [overload STK function]
%
% See also: stk_dataframe

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function x = stk_dataframe (x, colnames, rownames)

x = x.stk_dataframe;

if nargin > 1
    
    % Note: [] means "keep x.colnames" while {} means "no column names"
    if iscell (colnames)
        x = set (x, 'colnames', colnames);
    elseif ~ isempty (colnames)
        stk_error (['colnames should be either a cell array ' ...
            'of strings or [].'], 'InvalidArgument');
    end
    
    if nargin > 2
        
        % Note: [] means "keep x.rownames" while {} means "no row names"
        if iscell (rownames)
            x = set (x, 'rownames', rownames);
        elseif ~ isempty (rownames)
            stk_error (['rownames should be either a cell array ' ...
                'of strings or [].'], 'InvalidArgument');
        end
    end
    
end

end % function


%!shared x, cn, rn, y, cn2, rn2
%! cn = {'x' 'y'};
%! rn = {'lower_bounds'; 'upper_bounds'};
%! x = stk_hrect ([0 0; 1 1], cn);
%! cn2 = {'xx' 'yy'};
%! rn2 = {'aa'; 'bb'};

%!test y = stk_dataframe (x);
%!assert (strcmp (class (y), 'stk_dataframe'))
%!assert (isequal (y.colnames, cn))
%!assert (isequal (y.rownames, rn))

%!test y = stk_dataframe (x, cn2);
%!assert (strcmp (class (y), 'stk_dataframe'))
%!assert (isequal (y.colnames, cn2))
%!assert (isequal (y.rownames, rn))

%!test y = stk_dataframe (x, cn2, rn2);
%!assert (strcmp (class (y), 'stk_dataframe'))
%!assert (isequal (y.colnames, cn2))
%!assert (isequal (y.rownames, rn2))

%!test y = stk_dataframe (x, [], rn2);
%!assert (strcmp (class (y), 'stk_dataframe'))
%!assert (isequal (y.colnames, cn))
%!assert (isequal (y.rownames, rn2))

%!test y = stk_dataframe (x, {}, rn2);
%!assert (strcmp (class (y), 'stk_dataframe'))
%!assert (isequal (y.colnames, {}))
%!assert (isequal (y.rownames, rn2))
