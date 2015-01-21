% TEST SCRIPT FOR OPTIMIZATION STRATEGIES
% =======================================

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC & Ivana Aleksovska
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

stk_disp_examplewelcome;


%% Define test case

if ~ exist ('TESTCASE_NUM', 'var')
    TESTCASE_NUM = 1;
end

switch TESTCASE_NUM
    
    case 1,  % A one-dimensional test case
        
        DIM = 1;
        BOX = [-1.0; 1.0];
        
        f0 = @(x) ((0.8*x-0.2).^2 + exp(-0.5*(abs(x+0.1)/0.1).^1.95) ...
            + exp(-1/2*(2*x-0.6).^2/0.1) - 0.02);
        
        NOISEVARIANCE = 0.1 ^ 2;
        
        NT = 400;
        xt = stk_sampling_regulargrid (NT, DIM, BOX);
        
        xi_ind = [90 230 290 350];
        xi = xt(xi_ind, :);
        
    case 2,  % A two-dimensional test case
        
        DIM = 2;
        BOX = [[-1; 1], [-1; 1]];
        
        f_ = inline ('exp(1.8*(x1+x2)) + 3*x1 + 6*x2.^2 + 3*sin(4*pi*x1)', ...
            'x1', 'x2');  f0 = @(x)(- f_(x(:, 1), x(:, 2)));
        
        NOISEVARIANCE = 2 ^ 2;
        
        NT = 400; % nb of points in the grid
        xt = stk_sampling_regulargrid (NT, DIM, BOX);
        
        NI = 4;
        xi = stk_sampling_maximinlhs (NI, DIM, BOX);
        
    case 3
        
        DIM = 1;
        BOX = [-1.0; 1.0];
        
        f0  = @(x)((0.8*x-0.2).^2+1.0*exp(-1/2*(abs(x+0.1)/0.1).^1.95)+exp(-1/2*(2*x-0.6).^2/0.1)-0.02);
        
        NOISEVARIANCE =  0.1^2;
        
        NT = 400;
        xt = stk_sampling_regulargrid (NT, DIM, BOX);        
        
        xi_ind = [90 230 290 350];
        xi = xt(xi_ind, :);
               
end

% Ground truth
zt = stk_feval (f0, xt);


%% Noise variance

% Default: noisy function with known noise variance
if ~ exist ('NOISE', 'var')
    NOISE = 'known';  
end

switch NOISE
    
    case 'noiseless'
        % Optimize f0 directly (noiseless evaluations)
        f = f0;
        
    case {'known', 'unknown'}
        % Optimise f0 based on noisy evaluations                
        f = @(x)(f0(x) + sqrt (NOISEVARIANCE) * randn (size (x)));
        
        if strcmp (NOISE, 'known')
          f = {f, @(x)(NOISEVARIANCE)};
        end
end
        
%% Parameters of the optimization procedure

% Maximum number of iterations
if ~ exist ('MAX_ITER', 'var')
    MAX_ITER = 50;
end

% Use IAGO unless instructed otherwise
if exist ('CRIT', 'var')
    options = {'samplingcritname', CRIT};
else
    options = {'samplingcritname', 'IAGO'};
end

% Fake noisy data using simulated Gaussian noise
options = [options {'noise', 'known', 'noisevariance', NOISEVARIANCE}];

% Activate display (figures) and provide ground truth
options = [options { ...
    'disp', true, 'show1dsamplepaths', true, ...
    'disp_xvals', xt, 'disp_zvals', zt}];

% Do not pause (set this to true if you want time to look at the figures)
options = [options {'pause', false}];


%% Optimization

res = stk_optim (f, DIM, BOX, xi, MAX_ITER, options);


%!test MAX_ITER = 2;  CRIT = 'IAGO';    stk_optimscript;
% %!error MAX_ITER = 2;  CRIT = 'EI';      stk_optimscript;
% %!error MAX_ITER = 2;  CRIT = 'EI_v2';   stk_optimscript;
% %!error MAX_ITER = 2;  CRIT = 'EI_v3';   stk_optimscript;
%!xtest MAX_ITER = 2;  CRIT = 'EEI';     stk_optimscript;
%!xtest MAX_ITER = 2;  CRIT = 'EEI_v2';  stk_optimscript;
