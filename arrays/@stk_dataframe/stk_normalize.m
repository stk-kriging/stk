% STK_NORMALIZE [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function [x, a, b] = stk_normalize (x, box)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 2,
    box = [];
end

if isa (x, 'stk_dataframe')
    
    % Ensure that box is an stk_hrect object
    if ~ isa (box, 'stk_hrect')
        if isempty (box),
            box = stk_boundingbox (x.data);  % Default: bounding box
        else
            box = stk_hrect (box);
        end
    end
    
    % Call @stk_hrect/stk_normalize
    [x.data, a, b] = stk_normalize (x.data, box);
    
else % box is an stk_dataframe object
    
    % Call @stk_hrect/stk_normalize
    [x, a, b] = stk_normalize (x, stk_hrect (box));
    
end % if

end % function

%!test
%! u = rand (6, 2) * 2;
%! x = stk_dataframe (u);
%! y = stk_normalize (x);
%! assert (isa (y, 'stk_dataframe') ...
%!    && stk_isequal_tolabs (double (y), stk_normalize (u)))
