% SUBSREF [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function t = subsref (x, idx)

switch idx(1).type
    
    case '()'
        
        t = subsref (x.stk_dataframe, idx);
        
        if size (t, 1) == 2
            x.stk_dataframe = t;
            t = x;
        end
        
    case '{}'
        
        % Currently {}-indexing is not supported for
        % stk_dataframe objects, but who knows...
        t = subsref (x.stk_dataframe, idx);
        
    case '.'
        
        t = get (x, idx(1).subs);
        
        if length (idx) > 1,
            t = subsref (t, idx(2:end));
        end
        
end

end % function

%!test
%! B = stk_hrect ([0 0 0 0; 1 2 3 4]);
%! B = B(:, [1 3 4]);
%! assert (strcmp (class (B), 'stk_hrect'));
%! assert (isequal (double (B), [0 0 0; 1 3 4]));

%!test
%! B = stk_hrect ([0 0 0 0; 1 2 3 4]);
%! B = B(1, :);
%! assert (strcmp (class (B), 'stk_dataframe'));
%! assert (isequal (double (B), [0 0 0 0]));
