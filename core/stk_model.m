% STK_MODEL generates a model with default covariance parameters
%
% CALL: MODEL = stk_model()
%
%   returns a structure MODEL (see below for a description of the fields in such
%   a structure) corresponding to one-dimensional Gaussian process prior with a
%   constant but unknown mean ("ordinary" kriging) and a stationary Matern
%   covariance function.
%
% CALL: MODEL = stk_model(COVARIANCE_TYPE)
%
%   uses the user-supplied COVARIANCE_TYPE instead of the default.
%
% CALL: MODEL = stk_model(COVARIANCE_TYPE, DIM)
%
%   creates a DIM-dimensional model. Note that, for DIM > 1, anisotropic
%   covariance functions are provided with default parameters that make them
%   isotropic.
%
% In STK, a Gaussian process model is described by a 'model' structure,
% which has mandatory fields and optional fields.
%
%   MANDATORY FIELDS: covariance_type, param, order, lognoisevariance
%   OPTIONAL FIELD: param_prior, noise_prior, response_name, lm
%
% See also stk_materncov_iso, stk_materncov_aniso, ...

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function model = stk_model (covariance_type, varargin)

% Accept a handle instead of a function name
% (completion works when typing @stk_... not when typing 'stk_...)
if (nargin > 0) && (isa (covariance_type, 'function_handle'))
    covariance_type = func2str (covariance_type);
end

if nargin < 1,
    
    % use the (isotropic, 1D) Matern covariance function as a default choice
    model = stk_model_ ('stk_materncov_iso');
    
elseif strcmp (covariance_type, 'stk_discretecov')
    
    % special case: build a discrete model
    model = stk_model_discretecov (varargin{:});
    
else
    
    % general case
    model = stk_model_ (covariance_type, varargin{:});
    
end

end % function stk_model


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% stk_model_discretecov %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function model_out = stk_model_discretecov (model_base, x)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Backward compatiblity: accept model structures with missing lognoisevariance
if (~ isfield (model_base, 'lognoisevariance')) ...
        || (isempty (model_base.lognoisevariance))
    model_base.lognoisevariance = - inf;
end

[K, P] = stk_make_matcov (model_base, x, x);

model_out = struct ( ...
    'covariance_type', 'stk_discretecov', ...
    'param', struct ('K', K, 'P', P));

model_out.lognoisevariance = model_base.lognoisevariance;

end % function stk_model_discretecov


%%%%%%%%%%%%%%%%%%
%%% stk_model_ %%%
%%%%%%%%%%%%%%%%%%

function model = stk_model_ (covariance_type, dim)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

model = struct();

model.covariance_type = covariance_type;

% use ordinary kriging as a default choice
model.order = 0;

% default dimension is d = 1
if nargin < 2,
    model.dim = 1;
else
    model.dim = dim;
end

VAR0 = 1.0; % default value for the variance parameter

switch model.covariance_type
    
    case 'stk_materncov_iso'
        
        NU0 = 2.0;   % smoothness (regularity) parameter
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; NU0; 1/RHO]);
        
    case {'stk_materncov32_iso', 'stk_materncov52_iso', 'stk_gausscov_iso'}
        
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; 1/RHO]);
        
    case 'stk_materncov_aniso'
        
        NU0 = 2.0;   % smoothness (regularity) parameter
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; NU0; 1/RHO * ones(model.dim,1)]);
        
    case {'stk_materncov32_aniso', ...
            'stk_materncov52_aniso', 'stk_gausscov_aniso'}
        
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; 1/RHO * ones(model.dim,1)]);
        
    otherwise
        
        warning (['Unknown covariance type, model.param ' ...
            'cannot be initialized.']);  %#ok<WNTAG>
        
        model.param = [];
        
end % switch

model.lognoisevariance = - inf;

end % function stk_model_


%!test model = stk_model();

%!test model = stk_model('stk_materncov_iso');
%!test model = stk_model('stk_materncov_iso', 1);
%!test model = stk_model('stk_materncov_iso', 3);

%!test model = stk_model('stk_materncov_aniso');
%!test model = stk_model('stk_materncov_aniso', 1);
%!test model = stk_model('stk_materncov_aniso', 3);

%!test model = stk_model('stk_materncov32_iso');
%!test model = stk_model('stk_materncov32_iso', 1);
%!test model = stk_model('stk_materncov32_iso', 3);

%!test model = stk_model('stk_materncov32_aniso');
%!test model = stk_model('stk_materncov32_aniso', 1);
%!test model = stk_model('stk_materncov32_aniso', 3);

%!test model = stk_model('stk_materncov52_iso');
%!test model = stk_model('stk_materncov52_iso', 1);
%!test model = stk_model('stk_materncov52_iso', 3);

%!test model = stk_model('stk_materncov52_aniso');
%!test model = stk_model('stk_materncov52_aniso', 1);
%!test model = stk_model('stk_materncov52_aniso', 3);
