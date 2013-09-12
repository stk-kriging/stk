% STK_CONDITIONING produces conditioned sample paths.
%
% CALL: ZSIMC = stk_conditioning(LAMBDA, ZI, ZSIM, XI_IND)
%
%    produces conditioned sample paths ZSMIC from the unconditioned sample paths
%    ZSIM, using the matrix of kriging weights LAMBDA. Conditioning is done with
%    respect to a finite number NI of observations, located at the indices given
%    in XI_IND (vector of length NI), with corresponding observed values ZI.
%
%    The matrix LAMBDA must be of size NI x N, where N is the number of
%    evaluation points for the sample paths; such a matrix is typically provided
%    by stk_predict().
%
%    Both ZSIM and ZSIMC have size N x NB_PATHS, where NB_PATH is the number 
%    sample paths to be dealt with. ZI is a column of length NI.
%
% CALL: ZSIMC = stk_conditioning(LAMBDA, ZI, ZSIM)
%
%    assumes that the oberved values ZI correspond to the first NI evaluation
%    points.
%
% NOTE: stk_conditioning() uses the technique called "conditioning by kriging"
%    (see, e.g., Chiles and Delfiner, Geostatistics: Modeling Spatial
%    Uncertainty, Wiley, 1999)
%
% EXAMPLE: see STK/examples/example05.m
%
% See also stk_generate_samplepaths, stk_predict

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

function zsimc = stk_conditioning(lambda, zi, zsim, xi_ind)

if nargin > 4,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

zi = double(zi);
zsim = double(zsim);

[ni, n] = size(lambda);
m = size(zsim, 2);

if nargin < 4,
    xi_ind = (1:ni)';
else
    xi_ind = xi_ind(:);
end

if ~isequal(size(zi), [ni 1])
    stk_error('lambda and zi have incompatible sizes.', 'InvalidArgument');
end

if ~isequal(size(zsim), [n m])
    stk_error('lambda and zsim have incompatible sizes.', 'InvalidArgument');
end

if ~isequal(size(xi_ind), [ni 1])
    stk_error('lambda and xi_ind have incompatible sizes.', 'InvalidArgument');
end

delta = repmat(zi, 1, m) - zsim(xi_ind, :);
zsimc = stk_dataframe(zsim + lambda' * delta);

end


%!shared n m ni xi_ind lambda zsim zi
%!
%! n = 50; m = 5; ni = 10; xi_ind = 1:ni;
%! lambda = 1/ni * ones(ni, n);                % prediction == averaging
%! zsim = ones(n, m);                          % const unconditioned samplepaths
%! zi = zeros(ni, 1);                          % conditioning by zeros

%!error  zsimc = stk_conditioning();
%!error  zsimc = stk_conditioning(lambda);
%!error  zsimc = stk_conditioning(lambda, zi);
%!test   zsimc = stk_conditioning(lambda, zi, zsim);
%!test   zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
%!error  zsimc = stk_conditioning(lambda, zi, zsim, xi_ind, pi^2);

%!test
%! zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
%! assert(stk_isequal_tolabs(double(zsimc), zeros(n, m)));

%!test
%! zi = 2 * ones(ni, 1);          % conditioning by twos
%! zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
%! assert(stk_isequal_tolabs(double(zsimc), 2 * ones(n, m)));

%!test
%!
%! DIM = 1; nt = 400;
%! xt = stk_sampling_regulargrid(nt, DIM, [-1.0; 1.0]);
%!
%! NI = 6; xi_ind  = [1 20 90 200 300 350];
%! xi = xt(xi_ind, 1);
%! zi = (1:NI)';  % linear response ;-)
%!
%! % Carry out the kriging prediction at points xt
%! model = stk_model('stk_materncov_iso', DIM);
%! model = stk_setobs(model, xi, []);
%! [ignore_zp, lambda] = stk_predict(model, xt);
%!
%! % Generate (unconditional) sample paths according to the model
%! NB_PATHS = 10;
%! zsim = stk_generate_samplepaths(model, xt, NB_PATHS);
%! zsimc = stk_conditioning(lambda, zi, zsim, xi_ind);
