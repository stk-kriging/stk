% STK_DATAFRAME [FIXME: missing doc...]

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

function x = stk_dataframe(x0, colnames)

stk_narginchk(0, 3);

if nargin == 0,
    x0 = zeros(0, 1);
end

if isa(x0, 'stk_dataframe'),
 
    x = x0;

else
    
    x = struct();
    d = size(x0, 2);
    
    x.data = x0;
    
    if nargin > 1,
        if iscell(colnames)
            if (length(colnames) == d) && (numel(colnames) == d)
                x.vnames = colnames(:)';
            else
                errmsg = 'Incorrect size for argument ''colnames''.';
                stk_error(errmsg, 'IncorrectSize');
            end
        else
            errmsg = 'Incorrect type for argument ''colnames'' (should be a cell).';
            stk_error(errmsg, 'IncorrectType');
        end
    else
        if d == 1,
            x.vnames = {'x'};
        else
            x.vnames = cell(1, d);
            for j = 1:d,
                x.vnames{j} = sprintf('x%d', j);
            end
        end
    end
    
    x.rownames = {}; % default rownames will be displayed: 1, 2, ...
    
    x = class(x, 'stk_dataframe');
    
end

end % function stk_dataframe

%!test x = stk_dataframe();
