% STK_OPTIMSCRIPT2 ...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec & Ivana Aleksovska
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

DIM = 1;
BOX = stk_hrect ([-1.0; 1.0], {'x'});

f0 = @(x)(- (x - 0.7) .^2);

NOISEVARIANCE = 1 ^ 2;

% Candidate points for the optimization
nc = 31;
xc = stk_sampling_regulargrid (nc, DIM, BOX);

% Ground truth  (this grid of 400 is not actually used by the algorithm)
NT = 400;
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f0, xt);

% Optimise f0 based on noisy evaluations
%   (homoscedastic Gaussian noise)
f = @(x)(f0(x) + sqrt (NOISEVARIANCE) * randn (size (x)));

% Initial DoE: one batch of five every 6 candidate points
xi = repmat (xc(1:6:nc, :), 5, 1);
[xi, zi] = stk_gather_repetitions (xi, f(xi));


%% Parameters of the optimization procedure

% Maximum number of iterations
MAX_ITER = 1000;

% Sampling criterion: conditional entropy of the maximizer
options = {'samplingcritname', 'CEM'};  % (IAGO algorithm)

% % Use IID uniform sampling (constant criterion)
% % This demonstrate the use of a user-defined sampling criterion.
% options = {'samplingcritname', 'IID', ...
%     'samplingcrit', @(algo, x_obs, z_obs)(deal ( ...
%     stk_predict_withrep (algo.model, x_obs, z_obs, algo.xg0), ...
%     ones (stk_length (algo.xg0), 1)))};

% Homoscedastic noise, known noise variance
options = [options {'noisevariance', NOISEVARIANCE}];

% Activate display (figures) and provide ground truth
options = [options { ...
    'disp', true, 'show1dsamplepaths', true, ...
    'disp_xvals', xt, 'disp_zvals', zt, 'disp_period', 1}];

% Do not pause (set this to true if you want time to look at the figures)
options = [options {'pause', false}];

options = [options {'searchgrid_xvals', xc, ...
    'nsamplepaths', 500, 'quadorder', 15}];


%% Optimization

[x_opt, f_opt, ~, aux] = stk_optim (f, DIM, BOX, xi, zi, MAX_ITER, options);
