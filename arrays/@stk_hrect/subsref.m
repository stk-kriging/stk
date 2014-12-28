% SUBSREF [overload base function]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function t = subsref (x, idx)

switch idx(1).type
    
    case {'()', '{}'}
        
        t = subsref (x.stk_dataframe, idx);
        
    case '.'
        
        t = get (x, idx(1).subs);
        
        if length (idx) > 1,
            t = subsref (t, idx(2:end));
        end
        
end

end % function subsref