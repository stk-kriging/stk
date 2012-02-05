% Example 06 compares several kriging approximations in 1D
% ========================================================

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version:   1.0
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
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

%% Define 1d test function (the same as in example01.m)

f = @(x)( -(0.8*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space  
box = [-1.0; 1.0];                              % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_cartesiangrid( NT, DIM, box );
zt = stk_feval( f, xt );

NI = 6;                                     % nb of evaluations that will be used 
xi = stk_sampling_randunif(NI, DIM, box);   % evaluation points
zi = stk_feval(f, xi);                      % evaluation results


%% Several Matern models

NB_MODELS = 4; model = cell(1, NB_MODELS);

% Parameters used as initial values for stk_param_estim()
SIGMA2 = 1.0;  % variance parameter
NU     = 2.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter

%%% first, two Matern models with estimated regularity

% kriging with constant mean function ("ordinary kriging)
model{1} = struct('covariance_type', 'stk_materncov_iso', 'order', 0, ...
                  'param', [log(SIGMA2), log(NU), log(1/RHO1)]', ...
                  'lognoisevariance', log(100 * eps));

% kriging with affine mean function
model{2} = model{1}; 
model{2}.order = 1;

%%% two other Matern models with regularity parameter fixed to 5/2

% kriging with constant mean function ("ordinary kriging)
model{3} = struct('covariance_type', 'stk_materncov52_iso', 'order', 0, ...
                  'param', [log(SIGMA2), log(1/RHO1)]', ...
                  'lognoisevariance', log(100 * eps));
                 
% kriging with affine mean function
model{4} = model{3}; 
model{4}.order = 1;


%% Parameter estimation and prediction for each model

zp = cell(1, NB_MODELS);
nr = floor(sqrt(NB_MODELS));
nc = ceil(NB_MODELS / nr);

for j = 1:NB_MODELS,
    % Estimate the parameters of the covariance
    model{j}.param = stk_param_estim(model{j}.param, xi, zi, model{j});
    % Carry out kriging prediction
    zp{j} = stk_predict(xi, zi, xt, model{j});
    % Plot the result
    h_axis = subplot(nr, nc, j);
    stk_plot1d(xi, zi, xt, zt, zp{j}, h_axis);
    % Title
    switch model{j}.covariance_type,
        case 'stk_materncov52_iso',
            title(sprintf('Matern 5/2, order=%d', model{j}.order));
        case 'stk_materncov_iso',
            title(sprintf('Matern, estimated nu=%.2f, order=%d', ...
                  exp(model{j}.param(2)), model{j}.order));
    end
end
