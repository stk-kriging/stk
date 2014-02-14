% SUBSASGN [overloaded base function]

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

function x = subsasgn(x, idx, value)

if isa (x, 'stk_setobj_box')
    
    switch idx(1).type
        
        case '()'  % accessing the underlying 2 x d matrix
            
            bbox = [x.lb; x.ub];
            bbox = subsasgn (bbox, idx, value);
            
            d = size (bbox, 2);
            if ~ isequal (size (bbox), [2 d])
                stk_error('Illegal indexing.', 'IllegalIndexing');
            elseif any (diff (bbox) < 0)
                errmsg = 'Lower bounds cannot be greater than upper bounds !';
                stk_error (errmsg, 'InvalidArgument');
            else
                x.lb = bbox(1, :);
                x.ub = bbox(2, :);
            end
            
        case '{}'
            
            errmsg = 'Indexing with curly braces is not allowed.';
            stk_error(errmsg, 'IllegalIndexing');
            
        case '.'
            
            propname = idx(1).subs;
            
            if length (idx) > 1
                value = subsasgn (get (x, propname), idx(2:end), value);
            end
            
            x = set (x, propname, value);
            
    end

else  % then value must be an stk_setobj_box
    
    % try to interpret value as a 2 x d matrix
    x = subsasgn(x, idx, [value.lb; value.ub]);
    
end

end % function subsasgn
