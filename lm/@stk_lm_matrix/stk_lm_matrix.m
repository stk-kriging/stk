% STK_LM_MATRIX ... [FIXME: missing documentation]

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function lm = stk_lm_matrix (data)

if nargin == 0,
    lm = struct ('data', []);
else
    lm = struct ('data', data);
end

lm = class (lm, 'stk_lm_matrix');

end % function stk_lm_matrix


%!test %%% Default constructor
%! lm = stk_lm_matrix ();
%! assert (isa (lm, 'stk_lm_matrix'));

%!test %%% dim 1
%! data = rand (10, 1);  idx = 3:7;
%! lm = stk_lm_matrix (data);
%! assert (isa (lm, 'stk_lm_matrix'));
%! assert (isequal (data(idx, :), feval (lm, idx)));

%!test %%% dim 3
%! data = rand (10, 3);  idx = 3:7;
%! lm = stk_lm_matrix (data);
%! assert (isa (lm, 'stk_lm_matrix'));
%! assert (isequal (data(idx, :), feval (lm, idx)));
