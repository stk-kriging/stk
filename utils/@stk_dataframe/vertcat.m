% VERTICAL CONCATENATION [FIXME: missing doc...]

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

function x = vertcat(x, y, varargin)

stk_narginchk(2, inf);

if isa(x, 'stk_dataframe')
    if isa(y, 'stk_dataframe')
        % FIXME: check that variable names are identical !
        x.data = [x.data; y.data];
    else
        x.data = [x.data; y];
    end
else
    if isa(y, 'stk_dataframe')
        y.data = [x; y.data];
        x = y;
    else
        x = [x; y];
    end
end

if ~isempty(varargin),
    x = vertcat(x, varargin{:});
end

end % function subsref
