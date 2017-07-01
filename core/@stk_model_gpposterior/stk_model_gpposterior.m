% STK_MODEL_GPPOSTERIOR constructs a posterior model

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
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

function model = stk_model_gpposterior (prior_model, xi, zi)

if nargin == 3
    
    if iscell (xi)
        % Legacy support for experimental hidden feature, to be removed
        kreq = xi{2};  xi = xi{1};
    else
        kreq = [];
    end
    
    % Check the size of zi
    n = size (xi, 1);
    if ~ (isempty (zi) || isequal (size (zi), [n 1]))
        stk_error (['zi must either be empty or have the ' ...
            'same number of rows as x_obs.'], 'IncorrectSize');
    end
    
    % Currently, prior models are represented exclusively as structures
    if ~ isstruct (prior_model)
        stk_error (['Input argument ''prior_model'' must be a ' ...
            'prior model structure.'], 'InvalidArgument');
    end
    
    % Make sure that lognoisevariance is -inf for noiseless models
    if ~ stk_isnoisy (prior_model)
        prior_model.lognoisevariance = -inf;
    end
    
    % Backward compatibility:
    %   accept model structures with missing 'dim' field
    if (~ isfield (prior_model, 'dim')) || (isempty (prior_model.dim))
        prior_model.dim = size (xi, 2);
    elseif ~ isempty (xi) && (prior_model.dim ~= size (xi, 2))
        stk_error (sprintf (['The number of columns of xi (which is %d) ' ...
            'is different from the value of prior_model.dim (which is '   ...
            '%d).'], size (xi, 2), prior_model.dim), 'InvalidArgument');
    end
    
    % Check prior_model.lognoisevariance
    if ~ isscalar (prior_model.lognoisevariance)
        if (~ isvector (prior_model.lognoisevariance)) && (length ...
                (prior_model.lognoisevariance) == n)
            stk_error (['M_prior.lognoisevariance must be either ' ...
                'a scalar or a vector of length size (xi, 1).'], ...
                'InvalidArgument');
        end
        % Make sure that lnv is a column vector
        prior_model.lognoisevariance = prior_model.lognoisevariance(:);
    end
    
    % Check if the covariance model contains parameters
    % that must be estimated first
    if (isnumeric (prior_model.param)) && (any (isnan (prior_model.param)))
        prior_model.param = stk_param_estim (prior_model, xi, zi);
    end
    
    % Compute QR factorization
    if isempty (kreq)
        kreq = stk_kreq_qr (prior_model, xi);
    end
    
elseif nargin == 0
    
    prior_model = [];
    xi = [];
    zi = [];
    kreq = [];
    
else
    stk_error ('Incorrect number of input arguments.', 'SyntaxError');
end

% Prepare object fields
model.prior_model = prior_model;
model.input_data  = xi;
model.output_data = zi;
model.kreq        = kreq;

% Create object
model = class (model, 'stk_model_gpposterior');

end % function


%!test stk_test_class ('stk_model_gpposterior')

%!shared M_prior, x_obs, z_obs
%! x_obs = (linspace (0, pi, 15))';
%! z_obs = sin (x_obs);
%!
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);

%!test  M_post = stk_model_gpposterior ();
%!test  M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs]);
%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs], 3.441);

%!test % hidden feature
%! kreq = stk_kreq_qr (M_prior, x_obs);
%! M_post = stk_model_gpposterior (M_prior, {x_obs, kreq}, z_obs);

%!test % NaNs in prior_model.param
%! DIM = 1;  M = stk_model (@stk_materncov52_aniso, DIM);
%! M.param = nan (2, 1);  % this is currently the default
%! x = stk_sampling_regulargrid (20, DIM, [0; 1]);
%! y = sin (double (x));
%! zp = stk_predict (M, x, y, x);
