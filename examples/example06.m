% Example 06 compares several kriging approximations in 1D
% ========================================================

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

%% WELCOME

disp('                  ');
disp('#================#');
disp('#   Example 06   #');
disp('#================#');
disp('                  ');


%% DEFINE 1D TEST FUNCTION (THE SAME AS IN EXAMPLE01.M)

f = @(x)( -(0.8*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space
box = [-1.0; 1.0];                              % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_regulargrid( NT, DIM, box );
zt = stk_feval( f, xt );

NI = 6;                                     % nb of evaluations that will be used
xi = stk_sampling_randunif(NI, DIM, box);   % evaluation points
zi = stk_feval(f, xi);                      % evaluation results

obs = stk_makedata(xi, zi);


%% SEVERAL MATERN MODELS

NB_MODELS = 6; model = cell(1, NB_MODELS);

% Parameters used as initial values for stk_param_estim()
SIGMA2 = 1.0;  % variance parameter
NU     = 2.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
NOISE_VARIANCE = (1e-6)^2; % "rgularisation noise"

% First, two Matern models with estimated regularity
% 1) kriging with constant mean function (ordinary kriging)
model{1} = stk_model('stk_materncov_iso');
model{1}.randomprocess.priorcov.cparam = log([SIGMA2; NU; 1/RHO1]);
model{1}.noise.cov = stk_homnoisecov(NOISE_VARIANCE);
% 2) kriging with affine mean function
model{2} = model{1};
model{2}.randomprocess.priormean.param = 1; % order

% Two other Matern models with regularity parameter fixed to 3/2
% 3) kriging with constant mean function ("ordinary kriging)
model{3} = stk_model('stk_materncov52_iso');
model{3}.randomprocess.priorcov.cparam = log([SIGMA2; log(1/RHO1)]);
model{3}.noise.cov = stk_homnoisecov(NOISE_VARIANCE);
% 4) kriging with affine mean function
model{4} = model{3};
model{4}.randomprocess.priormean.param = 1; % order

% And two other Matern models with regularity parameter fixed to 5/2
% 5) kriging with constant mean function ("ordinary kriging)
model{5} = stk_model('stk_materncov32_iso');
model{5}.randomprocess.priorcov.cparam = log([SIGMA2; 1/RHO1]);
model{5}.noise.cov = stk_homnoisecov(NOISE_VARIANCE);
% 6) kriging with affine mean function
model{6} = model{5};
model{6}.randomprocess.priormean.param = 1; % order


%% PARAMETER ESTIMATION AND PREDICTION FOR EACH MODEL

zp = cell(1, NB_MODELS);
nc = floor(sqrt(NB_MODELS));
nr = ceil(NB_MODELS / nc);

for j = 1:NB_MODELS,
    model{j} = stk_setobs(model{j}, obs);
    % Estimate the parameters of the covariance
    model{j}.randomprocess.priorcov.cparam = ...
        stk_param_estim(model{j}, model{j}.randomprocess.priorcov.cparam);
    % Carry out kriging prediction
    zp{j} = stk_predict(model{j}, xt);
    % Plot the result
    h_axis = subplot(nr, nc, j);
    stk_plot1d(obs, stk_makedata(xt, zt), stk_makedata(xt, zp{j}));
    % Title
    order = model{j}.randomprocess.priormean.param;
    switch model{j}.randomprocess.priorcov.name,
        case 'stk_materncov32_iso',
            title(sprintf('Matern 3/2, order=%d', order));
        case 'stk_materncov52_iso',
            title(sprintf('Matern 5/2, order=%d', order));
        case 'stk_materncov_iso',
            nu = model{j}.randomprocess.priorcov.nu;
            %%% so ugly... the estimated parameter "nu" is stored in "prior"...
            title(sprintf('Matern, estimated nu=%.2f, order=%d', nu, order));
    end
end
