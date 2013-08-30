% STK_OPTIONS_GET returns the value of one or all STK options.

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

function argout = stk_options_get(varargin)

opts = stk_options_set();

switch nargin
    
    case 0, % nothing to do, just return the output
        argout = opts;
        
    case 1,
        argout = opts.(varargin{1});
        
    case 2,
        argout = opts.(varargin{1}).(varargin{2});
        
    otherwise
        stk_error('Too many input arguments.', 'TooManyInputArgs');
        
end

end % function stk_options_get
