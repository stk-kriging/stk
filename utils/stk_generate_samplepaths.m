% STK_GENERATE_SAMPLEPATHS generates sample paths of a Gaussian process
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
%
%    generates one sample path ZSIM of the Gaussian process MODEL discretized on
%    the evaluation points XT.  The input argument XT can be either a numerical
%    matrix or a dataframe.  The output argument ZSIM has the same number of
%    rows as XT.  More precisely, on a factor space of dimension DIM,
%
%     * XT must have size NS x DIM,
%     * ZSIM will have size NS x 1,
%
%    where NS is the number of simulation points.
%
%    Note that, in the case where MODEL is a model for noisy observations, this
%    function simulates sample paths of the underlying (latent) Gaussian
%    process, i.e., noiseless observations.
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
%
%    generates NB_PATHS sample paths at once.  In this case, the output argument
%    ZSIM has size NS x NB_PATHS.
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
%
%    generates one sample path ZSIM, using the kriging model MODEL and the
%    evaluation points XT, conditional on the evaluations (XI, ZI).
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
%
%    generates NB_PATHS conditional sample paths at once.
%
% NOTE: Sample size limitation
%
%    This function generates (discretized) sample paths using a Cholesky
%    factorization of the covariance matrix, and is therefore restricted to
%    moderate values of the number of evaluation points.
%
% NOTE: Output type
%
%    The output argument ZSIM is a plain (double precision) numerical array,
%    even if XT is a data frame.  Row names can be added afterwards as follows:
%
%       ZSIM = stk_generate_samplepaths (MODEL, XT);
%       ZSIM = stk_dataframe (ZSIM, {}, XT.rownames);
%
% EXAMPLES: see stk_example_kb05, stk_example_kb07
%
% See also stk_conditioning, stk_cholcov

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function zsim = stk_generate_samplepaths (model, varargin)

% Note: we know that none of the input argument is an stk_dataframe object
%  (otherwise we would have ended up in @stk_dataframe/stk_generate_samplepaths)

switch nargin
    
    case {0, 1}
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
        xt = varargin{1};
        nb_paths = 1;
        conditional = false;
        
    case 3
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
        xt = varargin{1};
        nb_paths = varargin{2};
        conditional = false;
        
    case 4
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = 1;
        conditional = true;
        
    case 5
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = varargin{4};
        conditional = true;
        
    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
        
end


%--- Process input arguments ---------------------------------------------------

% Extract row names from xt
xt = double (xt);

% Check nb_paths argument
nb_paths = double (nb_paths);
if ~ isscalar (nb_paths) || ~ (nb_paths > 0)
    stk_error ('nb_paths must be a positive scalar', 'Invalid argument');
end


%--- Extend xt with the observation points, if needed --------------------------

if conditional
    
    % Keep only numerical data for xi, zi
    xi = double (xi);
    zi = double (zi);
    
    % Conditioning by kriging => we must simulate on the observation points too
    xt = [xi; xt];
    xi_ind = 1:(size (xi, 1));
    
end

% FIXME: Avoid duplicating observations points if xi is a subset of xt


%--- Generate unconditional sample paths --------------------------------------

% Pick unique simulation points
[xt_unique, ignd, j] = unique (xt, 'rows');  %#ok<ASGLU> CG#07

% Did we actually find duplicates in xt ?
duplicates_detected = (size (xt_unique, 1) < size (xt, 1));

% Compute the covariance matrix
% (even if there no duplicates, it is not guaranteed
%  that xt_unique and xt are equal)
if duplicates_detected
    K = stk_make_matcov (model, xt_unique, xt_unique);
else
    K = stk_make_matcov (model, xt, xt);
end

% Cholesky factorization of the covariance matrix
V = stk_cholcov (K);

% Generates samplepaths
zsim = V' * randn (size (K, 1), nb_paths);

% Duplicate simulated values, if necessary
if duplicates_detected,  zsim = zsim(j, :);  end


%--- Generate conditional sample paths ----------------------------------------

if conditional
    
    % Carry out the kriging prediction at points xt
    [ignd, lambda] = stk_predict (model, xi, zi, xt);  %#ok<ASGLU> CG#07
    
    if ~ stk_isnoisy (model)
        
        % Simulate sample paths conditioned on noiseless observations
        zsim = stk_conditioning (lambda, zi, zsim, xi_ind);
        
    else % Noisy case
        
        % Simulate noise values
        s = sqrt (exp (model.lognoisevariance));
        ni = length (xi_ind);
        if isscalar (s)
            noise_sim = s * randn (ni, nb_paths);
        else
            s = reshape (s, ni, 1);
            noise_sim = bsxfun (@times, s, randn (ni, nb_paths));
        end
        
        % Simulate sample paths conditioned on noisy observations
        zsim = stk_conditioning (lambda, zi, zsim, xi_ind, noise_sim);
        
    end
    
    % TEMPORARY FIX (until stk_conditioning is fixed as well)
    zsim = double (zsim);
    
    zsim(xi_ind, :) = [];
    
end

end % function


%!shared model, xi, zi, xt, n, nb_paths
%! dim = 1;  n = 50;  nb_paths = 5;
%! model = stk_model ('stk_materncov32_iso', dim);
%! model.param = log ([1.0; 2.9]);
%! xt = stk_sampling_regulargrid (n, dim, [-1.0; 1.0]);
%! xi = [xt(1, :); xt(end, :)];  zi = [0; 0];

%!error zsim = stk_generate_samplepaths ();
%!error zsim = stk_generate_samplepaths (model);
%!test  zsim = stk_generate_samplepaths (model, xt);
%!test  zsim = stk_generate_samplepaths (model, xt, nb_paths);
%!test  zsim = stk_generate_samplepaths (model, xi, zi, xt);
%!test  zsim = stk_generate_samplepaths (model, xi, zi, xt, nb_paths);
%!error zsim = stk_generate_samplepaths (model, xi, zi, xt, nb_paths, log (2));

%!test
%! zsim = stk_generate_samplepaths (model, xt);
%! assert (isequal (size (zsim), [n, 1]));

%!test
%! zsim = stk_generate_samplepaths (model, xt, nb_paths);
%! assert (isequal (size (zsim), [n, nb_paths]));

%!test  % duplicate simulation points
%! zsim = stk_generate_samplepaths (model, [xt; xt], nb_paths);
%! assert (isequal (size (zsim), [2 * n, nb_paths]));
%! assert (isequal (zsim(1:n, :), zsim((n + 1):end, :)));

%!test  % simulation points equal to observation points (noiseless model)
%! % https://sourceforge.net/p/kriging/tickets/14/
%! zsim = stk_generate_samplepaths (model, xt, zeros (n, 1), xt);
%! assert (isequal (zsim, zeros (n, 1)));
