% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

function cov = subsasgn(cov, idx, value)

switch idx(1).type
    
    case '()'
        errmsg = 'Improper use of () indexing.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '{}'
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        propertyname = idx(1).subs;
        idx = idx(2:end);
        if isempty(idx)
            % simply set the field to rhs
            cov = set(cov, propertyname, value);
        else
            % several level of indexing... use a get/set combo !
            t = get(cov, propertyname);
            t = subsasgn(t, idx, value);
            cov = set(cov, propertyname, t);
        end
        
end

end % function subsref
