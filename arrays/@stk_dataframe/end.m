% END implements the the 'end' keyword for indexing

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@centralesupelec.fr>

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

function idx = end (x, k, nb_indices)

if nb_indices == 2,
    % using two indices (matrix-style indexing)
    idx = size (x.data, k);
else
    if nb_indices ~= 1,
        errmsg = 'stk_dataframe objects only support linear or matrix-style indexing.';
        stk_error (errmsg, 'IllegalIndexing');
    else
        % using linear indexing
        idx = numel (x.data);
    end
end

end % function


%--- tests with a univariate dataframe ----------------------------------------

%!shared x
%! x = stk_dataframe ([1; 2; 3]);
%!assert (isequal (double (x(2:end, :)), [2; 3]))
%!assert (isequal (double (x(2:end)),    [2; 3]))
%!assert (isequal (double (x(2, 1:end)), 2))
%!assert (isequal (double (x(end)),      3))

%--- tests with a bivariate dataframe -----------------------------------------

%!shared x
%! x = stk_dataframe ([1 2; 3 4; 5 6]);
%!assert (isequal (x(2:end, :), x(2:3, :)))
%!assert (isequal (x(2, 1:end), x(2, :)))
%!assert (isequal (x(2:end, 2:end), x(2:3, 2)))
%!error x(1:end, 1:end, 1:end)
