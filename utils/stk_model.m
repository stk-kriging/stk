% STK_MODEL generates a model with default parameters
%
% CALL: MODEL = stk_model(COVARIANCE_TYPE)
%
%   returns a structure MODEL (see below for a description of the fields in such
%   a structure) corresponding to a Gaussian process prior with a
%   constant but unknown mean ("ordinary" kriging), and the user-supplied
%   COVARIANCE_TYPE covariance function.
%
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
%                    priormean: [1x1 struct]
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
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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
function model = stk_model(covariance_type)
% =======
stk_narginchk(0, 2);

%=== set default values
                   
config        = struct('use_cache',       false, ...
                       'parallel_comput', false, ...
                       'guess_params',    true ...
                       );
private       = struct('config', config, ...
                       'Kx_cache', [], ...
                       'Px_cache', []);

dim = 1;
domain        = struct('type', 'continuous', ...
                       'dim',   dim, ...
                       'box',   [], ...
                       'xt',    [], ...
                       'nt',    0,  ...
                       'indicatorfunction', [] ...
                       );

priorcov      = struct('type', [], ...
                       'param', [] ...
                       );
priormean     = struct('type', 'polynomial', ...
                       'param', 0 ...
                      );
randomprocess = struct('type', 'GP', ...
                       'priormean', priormean, ...
                       'priorcov',  priorcov ...
                       );               

noise         = struct('type', 'none');

n             = 0;
x             = struct('a', zeros(n, dim));
z             = struct('a', zeros(n,1));
observations  = struct('x',  x, ...
                       'z',  z, ...
                       'n',  n ...
                       );

model         = struct('private',       private, ...
                       'domain',        domain, ...
                       'randomprocess', randomprocess, ...
                       'noise',         noise, ...
                       'observations',  observations ...
                       );


%%% covariance type

if nargin < 1,
    % use the (isotropic) Matern covariance function as a default choice
    % (note that, since nargin == 0 here, a one-dimensional will be produced)
    model.randomprocess.priorcov.type = 'stk_materncov_iso';
else
    model.randomprocess.priorcov.type = covariance_type;
end

%%% model.randomprocess.priormean

% use ordinary kriging as a default choice
model.randomprocess.priormean.type  = 'polynomial';
model.randomprocess.priormean.param = 0;

%%% model.param

VAR0 = 1.0; % default value for the variance parameter

switch model.randomprocess.priorcov.type
    
    case 'stk_materncov_iso'

        NU0 = 2.0;   % smoothness (regularity) parameter
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.randomprocess.priorcov.param = log([VAR0; NU0; 1/RHO]);

    case {'stk_materncov32_iso', 'stk_materncov52_iso'}

        RHO = 0.3;   % range parameter (spatial scale)
        
        model.randomprocess.priorcov.param = log([VAR0; 1/RHO]);
        
    case 'stk_materncov_aniso'

        NU0 = 2.0;   % smoothness (regularity) parameter
        RHO = 0.3;   % range parameter (spatial scale)
        
        model.randomprocess.priorcov.param = log([VAR0; NU0; 1/RHO ...
                            * ones(model.domain.dim, 1)]);

    case {'stk_materncov32_aniso', 'stk_materncov52_aniso'}

        RHO = 0.3;   % range parameter (spatial scale)
        
        model.randomprocess.priorcov.param = log([VAR0; 1/RHO * ...
                            ones(model.domain.dim, 1)]);

    otherwise
        
        warning('Unknown covariance type, model.param could not be initialized.');
        
        model.randomprocess.priorcov.param = [];

end


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
