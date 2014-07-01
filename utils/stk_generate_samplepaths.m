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
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
%
%    generates one sample path ZSIM, using the kriging model MODEL and the
%    evaluation points XT, conditional on the evaluations (XI, ZI).
%
% CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
%
%    generates NB_PATHS conditional sample paths at once.
%
% NOTE:
%
%    This function generates (discretized) sample paths using a Cholesky
%    factorization of the covariance matrix, and is therefore restricted to
%    moderate values of the number of evaluation points.
%
% EXAMPLES: see stk_example_kb05, stk_example_kb07
%
% See also stk_conditioning, stk_cholcov

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
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

function zsim = stk_generate_samplepaths (model, varargin)

switch nargin,
    
    case {0, 1},
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2,  % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
        xt = varargin{1};
        nb_paths = 1;
        conditional = false;
        
    case 3,  % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
        xt = varargin{1};
        nb_paths = varargin{2};
        conditional = false;
        
    case 4,  % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = 1;
        conditional = true;
        
    case 5,  % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
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
[xt_unique, ~, j] = unique (double (xt), 'rows');

% Did we actually find duplicates in xt ?
duplicates_detected = (size (xt_unique, 1) < size (xt, 1));

% Compute the covariance matrix
% (even if there no duplicates, it is not guaranteed that xt_unique and xt are equal)
if duplicates_detected,
    K = stk_make_matcov (model, xt_unique);
else
    K = stk_make_matcov (model, xt);
end

% Cholesky factorization of the covariance matrix
V = stk_cholcov (K);

% Generates samplepaths
zsim_data = V' * randn (size (K, 1), nb_paths);

% Duplicate simulated values, if necessary
if duplicates_detected,  zsim_data = zsim_data(j, :);  end

% output column names
try
    response_name = model.response_name;
    assert (isempty (response_name) || ischar (response_name));
    if ~ isempty (response_name)
        if nb_paths == 1,
            zsim_colnames = {response_name};
        else
            zsim_colnames = arrayfun ( ...
                @(i)(sprintf ('%s_%d', response_name, i)), ...
                1:nb_paths, 'UniformOutput', false);
        end
    end
catch
    zsim_colnames = {};
end

% output row names
try
    zsim_rownames = xt.rownames;
catch
    zsim_rownames = {};
end


%--- Generate conditional sample paths ----------------------------------------

if conditional,
    
    % Carry out the kriging prediction at points xt
    [zp_ignore, lambda] = stk_predict (stk_setobs (model, xi, zi), xt);  %#ok<ASGLU>
    
    % Condition sample paths on the observations
    zsim_data = stk_conditioning (lambda, zi, zsim_data, xi_ind);
    
    zsim_data(xi_ind, :) = [];
end


%--- The end ------------------------------------------------------------------

% store the result in a dataframe
zsim = stk_dataframe (zsim_data, zsim_colnames, zsim_rownames);

end % function stk_generate_samplepaths

%#ok<*CTCH>


%!shared model xi zi xt n nb_paths
%! dim = 1;  n = 50;  nb_paths = 5;
%! model = stk_model ('stk_materncov32_iso', dim);
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
