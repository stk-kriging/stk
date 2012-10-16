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

function t = subsref(model, idx)

switch idx(1).type
    
    case {'()', '{}'}
        stk_error('Syntax error', 'SyntaxError');
                
    case '.'
        t = subsref_(model, idx(1).subs, idx(2:end));
        
    otherwise % unexpected indexing type
        stk_error('Syntax error', 'SyntaxError');
        
end

end % function subsref



function t = subsref_(model, field, idx)

switch field,
    
    case {'randomprocess', 'noise', 'observations', 'domain'}
        
        if ~isempty(idx),
            t = subsref(model.(field), idx);
        else
            t = model.(field);
        end
        
    otherwise
        msg = sprintf('There is no field named %s.', field);
        stk_error(msg, 'UnknownField');
        
end

end % function subsref_
