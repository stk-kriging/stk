% VERTCAT concantenates one or several dataframes vertically

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

function z = vertcat(x, y, varargin)

if isa(x, 'stk_dataframe')
    
    % In this case, [x; y] will be an stk_dataframe also.
    
    data = [x.data; double(y)];
    
    if isa(y, 'stk_dataframe')
        
        if all(strcmp(x.vnames, y.vnames))
            colnames = x.vnames;
        else
            errmsg = 'Cannot concatenate because of incompatible column names.';
            stk_error(errmsg, 'IncompatibleColNames');
        end
        
        bx = isempty(x.rownames);
        by = isempty(y.rownames);
        if bx && by
            rownames = {};
        elseif ~bx && ~by
            rownames = [x.rownames; y.names];
        else
            errmsg = 'This kind of vertical concatenation is not implemented yet.';
            stk_error(errmsg, 'NotImplementedYet');
        end
        
    else % y is a matrix
        
        colnames = x.vnames;
        
        if isempty(x.rownames)
            rownames = {};
        else
            errmsg = 'This kind of vertical concatenation is not implemented yet.';
            stk_error(errmsg, 'NotImplementedYet');
        end
        
    end % if
    
    z = stk_dataframe(data, colnames, rownames);
    
else  % In this case, z will be a matrix.
    
    z = [double(x); double(y)];
    
end

if ~isempty(varargin),
    z = vertcat(z, varargin{:});
end

end % function subsref
