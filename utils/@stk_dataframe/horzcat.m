% HORZCAT concantenates one or several dataframes horizontally

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

function z = horzcat(x, y, varargin)

if isa(x, 'stk_dataframe') && isa(y, 'stk_dataframe')
    
    % In this case, [x y] will be an stk_dataframe also.
    
    data = [x.data y.data];
    colnames = [x.vnames y.vnames];
    if isempty(x.rownames),
        rownames = y.rownames;
    else
        if isempty(y.rownames) || all(strcmp(x.rownames, y.rownames))
            rownames = x.rownames;
        else
            errmsg = 'Cannot concatenate because of incompatible row names.';
            stk_error(errmsg, 'IncompatibleRowNames');
        end
    end
    z = stk_dataframe(data, colnames, rownames);
    
else % In this case, z will be a matrix.
    
    z = [double(x) double(y)];

end

if ~isempty(varargin),
    z = horzcat(z, varargin{:});
end

end % function horzcat
