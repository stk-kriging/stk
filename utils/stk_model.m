% STK_MODEL generates a model with default covariance parameters.
%
% CALL: MODEL = stk_model()
%
%   returns a structure MODEL (see below for a description of the fields in such
%   as structure) corresponding to one-dimensional Gaussian process prior with a
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
%   MANDATORY FIELDS: covariance_type, param
%   OPTIONAL FIELDS: Kx_cache, lognoisevariance
%
% See also stk_materncov_iso, stk_materncov_aniso, ...

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
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

function model = stk_model(covariance_type, dim)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

model = struct();

%%% covariance type

if nargin < 1,
    % use the (isotropic) Matern covariance function as a default choice
    % (note that, since nargin == 0 here, a one-dimensional will be produced)
    model.covariance_type = 'stk_materncov_iso';
else
    model.covariance_type = covariance_type;
end

%%% model.order

% use ordinary kriging as a default choice
model.order = 0;

%%% model.dim

% default dimension is d = 1
if nargin < 2,
    model.dim = 1;
else
    model.dim = dim;
end

%%% model.param

VAR0 = 1.0; % default value for the variance parameter

switch model.covariance_type
    
    case 'stk_materncov_iso'
        
        NU0 = 2.0;   % smoothness (regularity) parameter
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; NU0; 1/RHO]);
        
    case {'stk_materncov32_iso', 'stk_materncov52_iso'}
        
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; 1/RHO]);
        
    case 'stk_materncov_aniso'
        
        NU0 = 2.0;   % smoothness (regularity) parameter
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; NU0; 1/RHO * ones(model.dim,1)]);
        
    case {'stk_materncov32_aniso', 'stk_materncov52_aniso'}
        
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; 1/RHO * ones(model.dim,1)]);
        
    otherwise
        
        warning('Unknown covariance type, model.param cannot be initialized.');
        
        model.param = [];
        
end % switch

end % function stk_model


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

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
