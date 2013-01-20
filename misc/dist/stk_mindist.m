% STK_MINDIST computes the separation distance of a set of points
%
% CALL: D = stk_mindist(X)
%
%    computes the separation distance D of X. More precisely, if X is an
%    n x d matrix, then
%
%       D = min_{1 <= i < j <= n} norm(X(i,:) - X(j,:)),
%
%    where norm(.) denotes the Euclidean norm in R^d.
%
% See also: stk_dist, stk_filldist

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

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

function md = stk_mindist(x)

stk_narginchk(1, 1);

% call MEX-file
md = stk_mindist_mex(double(x));

end % function stk_mindist


%%
% Check that both double-precision matrices and stk_dataframe objects are accepted

%!test
%! d = 3; x = rand(7, d);
%! md1 = stk_mindist(x);
%! md2 = stk_mindist(stk_dataframe(x));
%! assert(stk_isequal_tolabs(md1, md2));

%%
% Check that sk_mindist(x) is empty when x has zero lines

%!test
%! for nc = [0 5 10],
%!   x = zeros(0, nc);
%!   d = stk_mindist(x);
%!   assert(isempty(d));
%! end

%%
% Check that sk_mindist(x) is empty when x has only one line.

%!test
%! for nc = [0 5 10],
%!   x = rand(1, nc);
%!   d = stk_mindist(x);
%!   assert(isempty(d));
%! end

%%
% Check that sk_mindist(x) is 0.0 when x has 0 columns (but at least 2 lines)

%!test
%! for nr = [2 5 10],
%!   x = zeros(nr, 0);
%!   d = stk_mindist(x);
%!   assert(isequal(d, 0.0));
%! end

%%
% Random matrices with at least 2 lines and 1 column

%!test
%!
%! nrep = 20;
%! TOL_REL = 1e-15;
%!
%! for irep = 1:nrep,
%!
%!     n = 2 + floor(rand * 10);
%!     d = 1 + floor(rand * 10);
%!     x = rand(n, d);
%!     z = stk_mindist(x);
%!
%!     assert(isequal(size(d), [1, 1]));
%!     assert(~isnan(d));
%!     assert(~isinf(d));
%!
%!     % check the result
%!     mindist = Inf;
%!     for i = 1:(n-1),
%!         for j = (i+1):n,
%!             mindist = min(mindist, norm(x(i,:) - x(j,:)));
%!         end
%!     end
%!     assert(abs(z - mindist) <= TOL_REL * mindist);
%!
%! end
