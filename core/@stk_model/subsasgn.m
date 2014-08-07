% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function model = subsasgn (model, idx, rhs)

switch idx(1).type
    
    case {'()', '{}'}
        stk_error ('Syntax error', 'SyntaxError');
        
    case '.'
        model = subsasgn_ (model, idx(1).subs, idx(2:end), rhs);
        
    otherwise % unexpected indexing type
        stk_error ('Syntax error', 'SyntaxError');
        
end

end % function subsasgn


function model = subsasgn_( model, field, idx, rhs)

switch field,
    
    case 'observations'
        
        msg = ['Direct assignment to ''observations'' '...
            '(or its fields) is not allowed; '];
        msg = [msg 'Please use stk_set_obs() instead.'];
        stk_error (msg, 'DirectAssignmentNotAllowed');
        
    case {'randomprocess', 'noise', 'domain'}
        
        if ~ isempty (idx),
            
            if ~ strcmp (idx(1).type, '.')
                stk_error ('Illegal subscripting.', 'SyntaxError');
            end
            
            subfield = idx(1).subs;
            if ~ isfield (model.(field), subfield)
                % creation of new fields is not authorized
                msg = sprintf ('%s.%s does not exist', field, idx(1).subs);
                stk_error (msg, 'PropertyDoesNotExist');
            end
            
            idx = idx(2:end);
            
            if isempty (idx),
                model.(field).(subfield) = rhs;
            else
                model.(field).(subfield) = ...
                    subsasgn (model.(field).(subfield), idx, rhs);
            end
            
        else
            
            msg = ['Direct assignment to randomprocess ' ...
                'is (currently) not allowed.'];
            stk_error (msg, 'DirectAssignmentNotAllowed');
            
        end
        
    case 'param'  % alias for .randomprocess.priorcov.param
        
        if ~ isempty (idx)
            rhs = subsasgn (model.randomprocess.priorcov.param, idx, rhs);
        end
        
        model.randomprocess.priorcov.param = rhs;
        
    otherwise
        msg = sprintf ('There is no field named %s.', field);
        stk_error (msg, 'UnknownField');
        
end % switch

end % function subsasgn_
