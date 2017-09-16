% @STK_FUNCTION/SUBSREF [overload base function]
%
% See also: subsref

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

function [value, argout2] = subsref (F, idx)

switch idx(1).type
    
    case '()'
        [value, argout2] = feval (F, idx(1).subs{:});
        
    case '{}'
        
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error (errmsg, 'IllegalIndexing');
        
    case '.'
        
        value = get (F, idx(1).subs);
        
end

if (length (idx)) > 1
    value = subsref (value, idx(2:end));
end

end % function
