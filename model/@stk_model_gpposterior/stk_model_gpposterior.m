% STK_MODEL_GPPOSTERIOR constructs a posterior model

% Copyright Notice
%
%    Copyright (C) 2015-2017, 2019, 2020 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function model = stk_model_gpposterior (prior_model, varargin)

switch nargin
    
    case 0  % Default constructor
        prior_model = [];
        data = stk_iodata ();
        
    case 2  % CALL: POSTERIOR = stk_model_gpposterior (PRIOR, DATA)
        stk_assert_model_struct (prior_model);
        data = varargin{1};
        if ~ isa (data, 'stk_iodata')
            stk_error (['An stk_iodata object was expected as second ' ...
                'input argument, since stk_model_gpposterior was ' ...
                'called with two input arguments.'], 'IncorrectArgument');
        end
        
    case 3  % CALL: POSTERIOR = stk_model_gpposterior (PRIOR, X_OBS, Z_OBS)
        stk_assert_model_struct (prior_model);
        data = stk_iodata (varargin{1}, varargin{2});
        
    otherwise
        stk_error ('Incorrect number of input arguments.', 'SyntaxError');
        
end % switch

% FIXME: check model.dim

switch data.output_dim
    
    case 0
        % SPECIAL CASE: used to construct partial GP models that can
        % provide prediction variances but no actual predictions.
        compute_predictions = false;
        
    case 1
        % This the usual case
        compute_predictions = true;
        
    otherwise
        stk_error ('Multi-output models are not supported yet', ...
            'NotImplementedYet');
        
end % switch

if isempty (prior_model)  % Default constructor only
    
    kreq = [];
    
else
    
    % Make sure that lognoisevariance is -inf for noiseless models
    if ~ stk_isnoisy (prior_model)
        prior_model.lognoisevariance = -inf;
    end
    
    % Backward compatibility:
    %   accept model structures with missing 'dim' field
    if (~ isfield (prior_model, 'dim')) || (isempty (prior_model.dim))
        prior_model.dim = data.input_dim;
    elseif prior_model.dim ~= data.input_dim
        stk_error (sprintf (['The input dimension of the data (which is ' ...
            '%d) differs from prior_model.dim (which is %d).'], ...
            data.input_dim, prior_model.dim), 'InvalidArgument');
    end
    
    % Check prior_model.lognoisevariance
    if ~ isscalar (prior_model.lognoisevariance)
        if ~ (isvector (prior_model.lognoisevariance) && ...
                (length (prior_model.lognoisevariance) == data.sample_size))
            stk_error (['M_prior.lognoisevariance must be either a scalar ' ...
                'or a vector of length equal to the sample size.'], ...
                'InvalidArgument');
        end
        % Make sure that lnv is a column vector
        prior_model.lognoisevariance = prior_model.lognoisevariance(:);
    end
    
    % Check if the model contains parameters that must be estimated first
    % (such parameters have the value NaN)
    param = stk_get_optimizable_model_parameters (prior_model);
    if any (isnan (param))
        noiseparam = stk_get_optimizable_noise_parameters (prior_model);
        
        if any (isnan (noiseparam))
            [prior_model.param, prior_model.lognoisevariance] ...
                = stk_param_estim (prior_model, data);
        else
            prior_model.param = stk_param_estim (prior_model, data);
        end
    end
    
    % Compute QR factorization
    kreq = stk_kreq_qr (prior_model, data);
end

% Prepare object fields
model.prior_model = prior_model;
model.data = data;
model.kreq = kreq;
model.compute_predictions = compute_predictions;

% Create object
model = class (model, 'stk_model_gpposterior', stk_model_ ());

end % function


%!test stk_test_class ('stk_model_gpposterior')

%!shared M_prior, x_obs, z_obs
%! x_obs = (linspace (0, pi, 15))';
%! z_obs = sin (x_obs);
%!
%! M_prior = stk_model (@stk_materncov32_iso);
%! M_prior.param = log ([1.0; 2.1]);

%!test  M_post = stk_model_gpposterior ();
%!test  M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs]);
%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs], 3.441);

%!test % NaNs in prior_model.param
%! DIM = 1;  M = stk_model (@stk_materncov52_aniso, DIM);
%! M.param = nan (2, 1);  % this is currently the default
%! x = stk_sampling_regulargrid (20, DIM, [0; 1]);
%! y = sin (double (x));
%! zp = stk_predict (M, x, y, x);
