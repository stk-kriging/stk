% SUBSASGN [overload base function]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function x = subsasgn (x, idx, val)

if ~ isa (x, 'stk_dataframe')
    % Inherit behaviour from @stk_dataframe
    %  (see @stk_dataframe/subsasgn.m)
    x = subsasgn (x, idx, val.stk_dataframe);
    return
end

if all (builtin ('size', x) == 0)
    % This happens in Octave 3.2.x when doing B(idx) = D if B does not
    % exist and D is an stk_factorialdesign object. In this case, x is an
    % UNITIALIZED 0x0 stk_factorialdesign object. We have to initialize it.
    x = stk_factorialdesign ();
end

switch idx(1).type
    
    case '()'
        % The result is not an stk_factorialdesign object anymore, in
        % general. An implicit cast to stk_dataframe is thus performed.
        x = x.stk_dataframe;
        x = subsasgn (x, idx, val);
        
    case '{}'
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        if length (idx) > 1
            val = subsasgn (get (x, idx(1).subs), idx(2:end), val);
        end
        x = set (x, idx(1).subs, val);
        
end

end % function subsasgn

