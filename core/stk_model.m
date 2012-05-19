% STK_MODEL generates a default model for the STK
%
% CALL: model = stk_model()
%       model = default kriging model
%
% STK_MODEL provides a default model, namely a stationary, isotropic
% Gaussian random process with constant but unknown mean. This should not
% be considered as a canonical choice.
%
% In STK, a Gaussian process model is described by a 'model' structure,
% which has mandatory fields and optional fields.
%
% MANDATORY FIELDS: name, param
%
% OPTIONAL FIELDS: Kx_cache, lognoisevariance
%
% FIXME: incomplete documentation
%
% FIXME: ici on documente la structure "model". On pourrait aussi s'en
% servir pour fournir des valeurs par defaut des parametres pour les
% differentes familles de covariance ?
%

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function model = stk_model(covariance_type, dim)

model = struct();

%%% covariance type

if nargin < 1,
    % use the anisotropic Matern covariance function as a default choice
    model.covariance_type = 'stk_materncov_aniso';
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
        
        model.param = log([VAR0; NU0; 1/RHO * ones(dim,1)]);

    case {'stk_materncov32_aniso', 'stk_materncov52_aniso'}

        RHO = 0.3;   % range parameter (spatial scale)
        
        model.param = log([VAR0; 1/RHO * ones(dim,1)]);

    otherwise
        
        warning('Unknown covariance type, model.param cannot be initialized.');
        
        model.param = [];

end