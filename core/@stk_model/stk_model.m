% STK_MODEL generates a model with default parameters
%
% CALL: MODEL = stk_model (COVARIANCE_TYPE)
%
%   returns a structure MODEL (see below for a description of the fields in such
%   a structure) corresponding to a Gaussian process prior with a
%   constant but unknown mean ("ordinary" kriging), and the user-supplied
%   COVARIANCE_TYPE covariance function.
%
%   [FIXME: obsolete doc, model is now an OBJECT !]
%   In STK, a Gaussian process model is described by a 'model' structure
%   with the following fields
%
%    * private: [1x1 struct]
%                       config: [1x1 struct]
%                     Kx_cache: []
%                     Px_cache: []
%    * domain: [1x1 struct]
%                         type: 'continuous', 'discrete
%                          dim: integer
%                          box: []
%                           xt: []
%                           nt: 0
%            indicatorfunction: []
%
%    * randomprocess: [1x1 struct]
%                         type: 'GP'
%                    priormean: a linear model [object of class stk_lm_* or handle]
%                     priorcov: [1x1 struct]
%    * noise: [1x1 struct]
%                         type: 'none', 'swn'
%             lognoisevariance: real
%    * observations: [1x1 struct]
%                            n: integer
%                            x: [1x1 struct]
%                            z: [1x1 struct]
%
% See also stk_materncov_iso, stk_materncov_aniso, ...

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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
%

function model = stk_model (covariance_type, varargin)

% Accept a handle instead of a function name
% (completion works when typing @stk_... not when typing 'stk_...)
if isa (covariance_type, 'function_handle')
    covariance_type = func2str (covariance_type);
end

if nargin < 1,
    
    % use the (isotropic, 1D) Matern covariance function as a default choice
    model = stk_model_ ('stk_materncov_iso');      

elseif strcmp (covariance_type, 'stk_discretecov')
    
    % special case: build a discrete model
    model = stk_model_discrete (varargin{:});
    
else
    
    % general case
    model = stk_model_ (covariance_type, varargin{:});
    
end

% NOTE: we should probably have two classes of models !

model = class(model, 'stk_model');

end % function stk_model


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% stk_model_discrete %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

function model = stk_model_discrete (model_base, x)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

model = prepare_empty_model_struct ();

% domain
model.domain.type = 'discrete';
model.domain.dim  = nan; % unused in the 'discrete' case
model.domain.nt   = size (x, 1); 

% mean and covariance functions
model.randomprocess.priormean = stk_lm_matrix ...
    (feval (model_base.randomprocess.priormean, x));
model.randomprocess.priorcov = stk_discretecov ...
    (feval (model_base.randomprocess.priorcov, x));

noisecov = model_base.noise.cov;
if isa (noisecov, 'stk_nullcov')
    model.noise.cov = stk_nullcov ();
else
    model.noise.cov = stk_discretecov (feval (noisecov, x));
end

end % function stk_model_discrete
 
 
%%%%%%%%%%%%%%%%%%
%%% stk_model_ %%%
%%%%%%%%%%%%%%%%%%

function model = stk_model_ (covariance_type, dim)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 2,
    dim = 1;
end

model = prepare_empty_model_struct ();

% domain
model.domain.type = 'continuous';
model.domain.dim  = dim;
model.domain.nt   = nan; % unused in the 'continuous' case

% observations
model.observations.n = 0;
model.observations.x = zeros (0, dim);
model.observations.z = zeros (0, 1);

% mean and covariance functions
model.randomprocess.priormean = stk_lm_constant; % default: ordinary kriging
model.randomprocess.priorcov = stk_cov (covariance_type, 'dim', dim);

end % function stk_model_


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% prepare_empty_model_struct %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function model = prepare_empty_model_struct ()

domain        = struct('type',  '',               ...
                       'dim',   [],               ...
                       'box',   [],               ...
                       'xt',    [],               ...
                       'nt',    0,                ...
                       'indicatorfunction', []    );

randomprocess = struct('type',     'GP',          ...
                       'priormean', [],           ...
                       'priorcov',  []            );

noise         = struct('cov', stk_nullcov());

observations  = struct('x',  [], ...
                       'z',  [], ...
                       'n',  0   );

model         = struct('domain',        domain,        ...
                       'randomprocess', randomprocess, ...
                       'noise',         noise,         ...
                       'observations',  observations   );

end % function prepare_empty_model_struct


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
