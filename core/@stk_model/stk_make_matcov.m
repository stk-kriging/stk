% STK_MAKE_MATCOV computes a covariance matrix (and a design matrix).
%
% CALL: [K, P] = stk_make_matcov(MODEL, X0)
%
%    computes the covariance matrix K and the design matrix P for the model
%    MODEL at the set of points X0. For a set of N points on a DIM-dimensional
%    space of factors, X0 is expected to be a structure whose field 'a' contains
%    an N x DIM matrix. As a result, a matrix K of size N x N and a matrix P of
%    size N x L are obtained, where L is the number of regression functions in
%    the linear part of the model; e.g., L = 1 if MODEL.randomprocess.priormean.param
%    is zero (ordinary kriging). [FIXME: obsolete doc]
%
% CALL: K = stk_make_matcov(MODEL, X0, X1)
%
%    computes the covariance matrix K for the model MODEL between the sets of
%    points X0 and X1. Both X0 and X1 are expected to be structures with an 'a'
%    field, containing the actual numerical data. The resulting K matrix is of
%    size N0 x N1, where N0 is the number of rows of XO and N1 the number of
%    rows of X1.
%
% BE CAREFUL:
%
%    stk_make_matcov(MODEL, X0) and stk_makematcov(MODEL, X0, X0) are NOT
%    equivalent, unless model.noise is an stk_nullcov (the noise variance is
%    added on the diagonal of the covariance matrix).

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function [K, P] = stk_make_matcov(model, x0, x1, pairwise)

%=== process input arguments

if nargin == 1,
    x0 = model.observations.x;
end

x0 = double(x0);

if (nargin > 2) && ~isempty(x1)
    x1 = double(x1);
    make_matcov_auto = false;
else
    x1 = x0;
    make_matcov_auto = true;
end

pairwise = (nargin > 3) && pairwise;

%=== compute the covariance matrix

K = feval(model.randomprocess.priorcov, x0, x1, -1, pairwise);

if make_matcov_auto && ~isa (model.noise.cov, 'stk_nullcov')
    if ~pairwise,
        K = K + feval(model.noise.cov, x0, x0, -1, pairwise);
    else
        stk_error('Not implemented yet.', 'NotImplementedYet');
    end
end

%=== compute the regression functions

if nargout > 1,
    P = feval(model.randomprocess.priormean, x0);
end

end

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared model, model2, x0, x1, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc
%! n0 = 20; n1 = 10; d = 4;
%! model = stk_model('stk_materncov_aniso', d);
%! model.randomprocess.priormean = stk_lm('affine');
%! model2 = model;
%! model2.noise.cov = stk_homnoisecov(0.1^2); % std 0.1
%! x0 = stk_sampling_randunif(n0, d);
%! x1 = stk_sampling_randunif(n1, d);

%!test  [KK, PP] = stk_make_matcov(model);
%!test  [Ka, Pa] = stk_make_matcov(model, x0);           % (1)
%!test  [Kb, Pb] = stk_make_matcov(model, x0, x0);       % (2)
%!test  [Kc, Pc] = stk_make_matcov(model, x0, x1);       % (3)
%!error [KK, PP] = stk_make_matcov(model, x0, x1, pi);

%!test  assert(isequal(size(Ka), [n0 n0]));
%!test  assert(isequal(size(Kb), [n0 n0]));
%!test  assert(isequal(size(Kc), [n0 n1]));

%!test  assert(isequal(size(Pa), [n0 d + 1]));
%!test  assert(isequal(size(Pb), [n0 d + 1]));
%!test  assert(isequal(size(Pc), [n0 d + 1]));

%!% In the noiseless case, (1) and (2) should give the same results
%!test  assert(isequal(Kb, Ka));

%!% In the noisy case, however...
%!test  [Ka, Pa] = stk_make_matcov(model2, x0);           % (1')
%!test  [Kb, Pb] = stk_make_matcov(model2, x0, x0);       % (2')
%!error assert(isequal(Kb, Ka));

%!% The second output depends on x0 only => should be the same for (1)--(3)
%!test  assert(isequal(Pa, Pb));
%!test  assert(isequal(Pa, Pc));
