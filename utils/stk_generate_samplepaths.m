% STK_GENERATE_SAMPLEPATHS generates sample paths of a Gaussian process.
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
%
%    generates one sample path ZSIM, using the kriging model MODEL and the
%    evaluation points XT. Both XT and ZSIM are structures, whose field 'a'
%    contains the actual numerical values.
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
%
%    generates NB_PATHS sample paths at once.
%
% NOTE:
%
%    This function generates (discretized) sample paths using a Cholesky
%    factorization of the covariance matrix, and is therefore restricted to
%    moderate values of the number of evaluation points.
%
% EXAMPLE: see STK/examples/example05.m
%
% See also stk_conditioning, chol

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

function zsim = stk_generate_samplepaths (model, xt, nb_paths)

if nargin > 3,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 3,
    nb_paths = 1;
end

% covariance matrix
K = stk_make_matcov (model, xt);

% Cholesky factorization, once and for all
V = chol (K);

% generates samplepaths
zsim_data = V' * randn (size (K, 1), nb_paths);

% store the result in a dataframe
zsim_varnames = arrayfun (@(i)(...
    sprintf ('z%d', i)), 1:nb_paths, 'UniformOutput', false);
zsim = stk_dataframe (zsim_data, zsim_varnames);

end % function stk_generate_samplepaths


%!shared model xt n nb_paths
%! dim = 1;  n = 400;  nb_paths = 5;
%! model = stk_model ('stk_materncov32_iso', dim);
%! xt = stk_sampling_regulargrid (n, dim, [-1.0; 1.0]);

%!error zsim = stk_generate_samplepaths ();
%!error zsim = stk_generate_samplepaths (model);
%!test  zsim = stk_generate_samplepaths (model, xt);
%!test  zsim = stk_generate_samplepaths (model, xt, nb_paths);
%!error zsim = stk_generate_samplepaths (model, xt, nb_paths, log (2));

%!test
%! zsim = stk_generate_samplepaths (model, xt);
%! assert (isequal (size (zsim), [n, 1]));

%!test
%! zsim = stk_generate_samplepaths (model, xt, nb_paths);
%! assert (isequal (size (zsim), [n, nb_paths]));
