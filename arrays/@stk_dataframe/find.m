% @STK_DATAFRAME/FIND [overload base function]
%
% See also: find

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

function varargout = find (x, varargin)

if isa (x, 'stk_dataframe')
    
    varargout = cell (1, max (nargout, 1));
    [varargout{:}] = find (logical (x), varargin{:});
    
else
    
    stk_error (['@stk_dataframe/find only supports stk_dataframe objects ' ...
        'for the first input argument.'], 'InvalidArgument');
    
end

end % function
