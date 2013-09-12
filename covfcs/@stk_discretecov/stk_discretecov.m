% STK_DISCRETECOV...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function cov = stk_discretecov (K)

if nargin == 0,
    % default constructor
    prop = struct ('K', []);
else
    prop = struct ('K', K);
end

cov = struct ('prop', prop, 'aux', []);

cov = class (cov, 'stk_discretecov', stk_cov());

end % function stk_discretecov


%!shared model, model2, x0
%! n0 = 20; n1 = 10; dim = 4;
%! x0 = stk_sampling_randunif (n0, dim);
%! x1 = stk_sampling_randunif (n1, dim);
%! model = stk_model ('stk_materncov_aniso', dim);
%! model.randomprocess.priormean = stk_lm ('linear');

%!test % without noise, pairwise = false
%! model.noise.cov = stk_nullcov ();
%! model2 = stk_model ('stk_discretecov', model, x0);
%! idx = [1 4 9];
%! [K1, P1] = stk_make_matcov (model,  x0(idx, :));
%! [K2, P2] = stk_make_matcov (model2, idx');
%! assert (stk_isequal_tolrel (K1, K2));
%! assert (stk_isequal_tolrel (P1, P2));

%!test % without noise, pairwise = true
%! K1 = stk_make_matcov (model,  x0([2 5 6], :), [], true);
%! K2 = stk_make_matcov (model2, [2 5 6]', [], true);
%! assert (stk_isequal_tolrel (K1, K2));

%!test % with noise, pairwise = false
%! model.noise.cov = stk_homnoisecov (0.01);
%! model2 = stk_model ('stk_discretecov', model, x0);
%! idx = [1 4 9];
%! [K1, P1] = stk_make_matcov (model,  x0(idx, :));
%! [K2, P2] = stk_make_matcov (model2, idx');
%! assert (stk_isequal_tolrel (K1, K2));
%! assert (stk_isequal_tolrel (P1, P2));
