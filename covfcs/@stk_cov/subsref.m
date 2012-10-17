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

function t = subsref(cov, idx)

switch idx(1).type
    
    case '()'
        t = feval(cov, idx(1).subs{:});
        
    case '{}'
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        t = get(cov, idx(1).subs);
        
end

% handle additional indices
idx = idx(2:end);
if ~isempty(idx),
    try
        % this is how it should be written...
        t = subsref(t, idx);        
    catch
        % but sometimes if fails... (for instance when subscripting an 
        % object field in a structure, apparently)
        err0 = lasterror();
        try
            while ~isempty(idx),
                t = subsref(t, idx(1));
                idx = idx(2:end);
            end
        catch
            % if even the workaround fails, I give up
            rethrow(err0);
        end
    end
end

end % function subsref
