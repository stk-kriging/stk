% MIN computes the minimum of each variable in a dataframe

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

function z = min(x, y, dim)
stk_narginchk(1, 3);

if (nargin < 2) || isempty(y), %--- action on rows or columns ---------------------------
   
    if nargin < 3, dim = 1; end
    
    z = apply(x, dim, @min, []);
        
else %--- apply 'min' elementwise -------------------------------------------------------

    if nargin > 2,
        errmsg = 'Too many input arguments (elementwise min assumed)';
        stk_error(errmsg, 'TooManyInputArgs');
    else
        z = bsxfun(@min, x, y);
    end
    
end %--- that's all, folks --------------------------------------------------------------

end % function min


%!test  stk_test_dfbinaryop(@min, rand(7, 2), rand(7, 2));
%!test  stk_test_dfbinaryop(@min, rand(7, 2), pi);
%!error stk_test_dfbinaryop(@min, rand(7, 2), rand(7, 3));

%!shared x1 df1
%! x1 = rand(9, 3);
%! df1 = stk_dataframe(x1, {'a', 'b', 'c'});
%!assert (isequal (min(df1),        min(x1)))
%!assert (isequal (min(df1, [], 1), min(x1)))
%!assert (isequal (min(df1, [], 2), min(x1, [], 2)))
%!error (min(df1, df1, 2))
