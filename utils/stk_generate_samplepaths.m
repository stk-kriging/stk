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
% NOTE: Conditional simulations
%
%    This functions generates "conditional simulations" if MODEL is a
%    posterior model object.  In order to simulate conditional sample paths
%    from a prior model object MODEL and data (XI, ZI), use:
%
%    MODEL = stk_model_update (MODEL, XI, ZI);
%    SIM = stk_generate_samplepaths (MODEL, ...);
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
%    Copyright (C) 2015-2018, 2021, 2022 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

if nargin < 2
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
    
elseif nargin > 3
    % One of the following (deprecated) syntaxes:
    %    ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
    %    ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
    
    model = stk_model_update (model, varargin{1}, varargin{2});
    varargin(1:2) = [];
    
end

zsim = stk_generate_samplepaths_ (model, varargin{:});

end


function zsim = stk_generate_samplepaths_ (model, xt, nb_paths)

%--- Process input arguments ---------------------------------------------------

xt = double (xt);

% Check nb_paths argument
if nargin < 3
    nb_paths = 1;
else
    nb_paths = double (nb_paths);
    if ~ isscalar (nb_paths) || ~ (nb_paths > 0)
        stk_error ('nb_paths must be a positive scalar', 'Invalid argument');
    end
end


%--- Extend xt with the observation points, if needed --------------------------

n = stk_get_sample_size (model);
conditional = (n > 0);

if conditional
    
    data = model.data;  % FIXME: Write/use a getter instead
    M_prior = stk_get_prior_model (model);
    
    % Conditioning by kriging => we must simulate on the observation points too
    xi = double (stk_get_input_data (data));
    xt = [xi; xt];
    xi_ind = 1:n;
    
else
    
    M_prior = model;
    
end

% FIXME: Avoid duplicating observations points if xi is a subset of xt


%--- Generate unconditional sample paths --------------------------------------

% Pick unique simulation points
[xt_unique, ~, j] = unique (xt, 'rows');

% Did we actually find duplicates in xt ?
duplicates_detected = (size (xt_unique, 1) < size (xt, 1));

% Compute the covariance matrix
% (even if there no duplicates, it is not guaranteed
%  that xt_unique and xt are equal)
if duplicates_detected
    K = stk_make_matcov (M_prior, xt_unique, xt_unique);
else
    K = stk_make_matcov (M_prior, xt, xt);
end

% Cholesky factorization of the covariance matrix
V = stk_cholcov (K);

% Generates samplepaths
zsim = V' * randn (size (K, 1), nb_paths);

% Duplicate simulated values, if necessary
if duplicates_detected,  zsim = zsim(j, :);  end


%--- Generate conditional sample paths ----------------------------------------

if conditional
    
    % Compute the kriging weights at points xt
    [~, lambda] = stk_predict (model, xt);
    
    % Extract observations
    zi = double (stk_get_output_data (data));
    
    if ~ stk_isnoisy (M_prior)
        
        % Simulate sample paths conditioned on noiseless observations
        zsim = stk_conditioning (lambda, zi, zsim, xi_ind);
        
    else % Noisy case
        
        % Simulate noise values
        noise_sim = stk_simulate_noise (M_prior, data, nb_paths);
        
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
%! model = stk_model (@stk_materncov32_iso, dim);
%! model.param = log ([1.0; 2.9]);
%! xt = stk_sampling_regulargrid (n, dim, [-1.0; 1.0]);
%! xi = [xt(1, :); xt(end, :)];  zi = [0; 0];

%!error zsim = stk_generate_samplepaths ();
%!error zsim = stk_generate_samplepaths (model);
%!test  zsim = stk_generate_samplepaths (model, xt);
%!test  zsim = stk_generate_samplepaths (model, xt, nb_paths);
%!test  zsim = stk_generate_samplepaths (model, xi, zi, xt);
%!test  zsim = stk_generate_samplepaths (model, xi, zi, xt, nb_paths);

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
