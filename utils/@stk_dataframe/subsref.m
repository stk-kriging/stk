% SUBSREF [FIXME: missing doc...]

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

function t = subsref(x, idx)

switch idx(1).type
    
    case '()'
        t = subsref(x.data, idx);
        
    case '{}'
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        b = strcmp(idx(1).subs, x.varnames);
        switch sum(b),
            case 0
                errmsg = sprintf('There is no variable named %s.', idx(1).subs);
                stk_error(errmsg, 'UnknownVariable');
            case 1
                t = x.data(:, b);
            otherwise
                errmsg = 'This should NEVER happen (corrupted stk_dataframe).';
                stk_error(errmsg, 'CorruptedObject');
        end
        
end

if length(idx) > 1,
    t = subsref(t, idx(2:end));
end

end % function subsref
