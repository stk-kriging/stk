% STK_MODEL generates a model with default covariance parameters
%
% CALL: MODEL = stk_model ()
%
%   returns a structure MODEL (see below for a description of the fields in such
%   a structure) corresponding to one-dimensional Gaussian process prior with a
%   constant but unknown mean ("ordinary" kriging) and a stationary Matern
%   covariance function.
%
% CALL: MODEL = stk_model (COVARIANCE_TYPE)
%
%   uses the user-supplied COVARIANCE_TYPE instead of the default.
%
% CALL: MODEL = stk_model (COVARIANCE_TYPE, DIM)
%
%   creates a DIM-dimensional model. Note that, for DIM > 1, anisotropic
%   covariance functions are provided with default parameters that make them
%   isotropic.
%
% In STK, a Gaussian process model is described by a 'model' structure,
% which has mandatory fields and optional fields.
%
%   MANDATORY FIELDS: covariance_type, param, lm, lognoisevariance
%   OPTIONAL FIELD: param_prior, noise_prior
%
% See also stk_materncov_iso, stk_materncov_aniso, ...

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

function model = stk_model (covariance_type, varargin)

% Extract a handle and a name from what we are given
if nargin > 0
    if isa (covariance_type, 'function_handle')
        covariance_name = func2str (covariance_type);
    elseif ischar (covariance_type)
        covariance_name = covariance_type;
        covariance_type = str2func (covariance_type);
    else
        stk_error (['covariance_type should be a function name or a handle to ' ...
            'a function.'], 'TypeMismatch');
    end
else
    covariance_type = @stk_materncov_iso;
    covariance_name = 'stk_materncov_iso';
end

if strcmp (covariance_name, 'stk_discretecov')
    
    % special case: build a discrete model
    model = stk_model_discretecov (varargin{:});
    
else
    
    % general case
    model = stk_model_ (covariance_type, covariance_name, varargin{:});
    
end

end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% stk_model_discretecov %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function model_out = stk_model_discretecov (model_base, x)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Make sure that lognoisevariance is -inf for noiseless models
if ~ stk_isnoisy (model_base)
    model_base.lognoisevariance = -inf;
end

[K, P] = stk_make_matcov (model_base, x, x);

model_out = struct ( ...
    'covariance_type', 'stk_discretecov', ...
    'param', struct ('K', K, 'P', P));

if ~ isscalar (model_base.lognoisevariance)
    error ('This case is not supported.');
else
    model_out.lognoisevariance = model_base.lognoisevariance;
end

end % function


%%%%%%%%%%%%%%%%%%
%%% stk_model_ %%%
%%%%%%%%%%%%%%%%%%

function model = stk_model_ (covariance_type, covariance_name, dim)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

model = struct();

model.covariance_type = covariance_type;

% use ordinary kriging as a default choice
model.lm = stk_lm_constant ();

% default dimension is d = 1
if nargin < 3,
    model.dim = 1;
else
    model.dim = dim;
end

% For known covariance types, the field param is initialized with a vector of
% nan of the appropriate size.  This serves as a reminder, for the user, of the
% correct size for a parameter vector---nothing more.
switch covariance_name
    
    case 'stk_materncov_iso'
        model.param = nan (3, 1);
        
    case {'stk_expcov_iso', 'stk_materncov32_iso', 'stk_materncov52_iso', ...
            'stk_gausscov_iso', 'stk_sphcov_iso'}
        model.param = nan (2, 1);
        
    case 'stk_materncov_aniso'
        model.param = nan (2 + model.dim, 1);
        
    case {'stk_expcov_aniso', 'stk_materncov32_aniso', ...
            'stk_materncov52_aniso', 'stk_gausscov_aniso', 'stk_sphcov_aniso'}
        model.param = nan (1 + model.dim, 1);
        
    otherwise
        model.param = [];
        
end % switch

model.lognoisevariance = - inf;

end % function


%!test model = stk_model();

%!test model = stk_model('stk_expcov_iso');
%!test model = stk_model('stk_expcov_iso', 1);
%!test model = stk_model('stk_expcov_iso', 3);

%!test model = stk_model('stk_expcov_aniso');
%!test model = stk_model('stk_expcov_aniso', 1);
%!test model = stk_model('stk_expcov_aniso', 3);

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

%!test model = stk_model('stk_gausscov_iso');
%!test model = stk_model('stk_gausscov_iso', 1);
%!test model = stk_model('stk_gausscov_iso', 3);

%!test model = stk_model('stk_gausscov_aniso');
%!test model = stk_model('stk_gausscov_aniso', 1);
%!test model = stk_model('stk_gausscov_aniso', 3);

%!test model = stk_model('stk_sphcov_iso');
%!test model = stk_model('stk_sphcov_iso', 1);
%!test model = stk_model('stk_sphcov_iso', 3);

%!test model = stk_model('stk_sphcov_aniso');
%!test model = stk_model('stk_sphcov_aniso', 1);
%!test model = stk_model('stk_sphcov_aniso', 3);
