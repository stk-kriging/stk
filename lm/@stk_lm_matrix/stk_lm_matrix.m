% STK_LM_MATRIX creates a linear model object defined on a finite space
%
% CALL: LM = STK_LM_MATRIX (P)
%
%    creates a linear model object LM with "design matrix" P.  Such an object
%    describes a linear model on a finite space of cardinality N, where N is the
%    number of rows of P.

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
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

function lm = stk_lm_matrix (data)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin == 0
    lm = struct ('data', []);
else
    lm = struct ('data', data);
end

lm = class (lm, 'stk_lm_matrix');

end % function


%!test stk_test_class ('stk_lm_matrix')

%!error lm = stk_lm_matrix ([], 3.33);

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
