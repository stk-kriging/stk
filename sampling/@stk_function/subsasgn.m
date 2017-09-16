% @STK_FUNCTION/SUBSASGN [overload base function]
%
% See also: subsasgn

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function F = subsasgn (F, idx, value)

switch idx(1).type
    
    case '.'
        
        if length (idx) > 1
            value = subsasgn (get (F, idx(1).subs), idx(2:end), value);
        end
        
        F = set (F, idx(1).subs, value);
        
    case {'{}', '()'}
        
        errmsg = 'Illegal assignment';
        stk_error (errmsg, 'IllegalAssignment');
        
end

end % function
