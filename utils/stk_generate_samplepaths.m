% STK_GENERATE_SAMPLEPATHS generates sample paths of a Gaussian process
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
%    The output argument ZSIM will be an stk_dataframe if at least one of the
%    following conditions is met:
%
%      a) the MODEL structure has a non-empty char field named 'response_name';
%
%      b) one of the input arguments XT, XI or ZI is an stk_dataframe object.
%
%    If both MODEL.response_name and ZI.colnames exist and are non-empty, they
%    must be equal (if they are not, ZSIM.colnames is empty).
%
% EXAMPLES: see stk_example_kb05, stk_example_kb07
%
% See also stk_conditioning, stk_cholcov

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
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

switch nargin,
    
    case {0, 1},
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
        xt = varargin{1};
        nb_paths = 1;
        conditional = false;
        
    case 3,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
        xt = varargin{1};
        nb_paths = varargin{2};
        conditional = false;
        
    case 4,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = 1;
        conditional = true;
        
    case 5,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = varargin{4};
        conditional = true;
        
    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
        
end

% Prepare extended dataset for conditioning, if required
% (TODO: avoid duplicating observations points if xi is a subset of xt)
if conditional,
    xt = [xi; xt];
    xi_ind = 1:(size (xi, 1));
end


%--- Generate unconditional sample paths --------------------------------------

% Pick unique simulation points
[xt_unique, i_ignore, j] = unique (xt, 'rows');  %#ok<ASGLU>

% Did we actually find duplicates in xt ?
duplicates_detected = (size (xt_unique, 1) < size (xt, 1));

% Compute the covariance matrix
% (even if there no duplicates, it is not guaranteed
%  that xt_unique and xt are equal)
if duplicates_detected,
    K = stk_covmat_latent (model, xt_unique, xt_unique);
else
    K = stk_covmat_latent (model, xt, xt);
end

% Cholesky factorization of the covariance matrix
V = stk_cholcov (K);

% Generates samplepaths
zsim = V' * randn (size (K, 1), nb_paths);

% Duplicate simulated values, if necessary
if duplicates_detected,  zsim = zsim(j, :);  end


%--- Generate conditional sample paths ----------------------------------------

if conditional,
    
    % Make sure that lognoisevariance is -inf for noiseless models
    if ~ stk_isnoisy (model)
        model.lognoisevariance = -inf;
    end
    
    % Carry out the kriging prediction at points xt
    [zp_ignore, lambda] = stk_predict (model, xi, zi, xt);  %#ok<ASGLU>
    
    if model.lognoisevariance == -inf,
        
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


%--- stk_dataframe output ?  --------------------------------------------------

try %#ok<TRYNC>
    
    response_name = model.response_name;
    assert ((~ isempty (response_name)) && (ischar (response_name)));
    
    if nb_paths == 1,
        zsim_colnames = {response_name};
    else
        zsim_colnames = arrayfun ( ...
            @(i)(sprintf ('%s_%d', response_name, i)), ...
            1:nb_paths, 'UniformOutput', false);
    end
    
    zsim = stk_dataframe (zsim, zsim_colnames);
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
