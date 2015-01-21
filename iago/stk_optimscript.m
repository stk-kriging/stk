% TEST SCRIPT FOR OPTIMIZATION STRATEGIES
% =======================================

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Ivana Aleksovska  <ivanaaleksovska@gmail.com>
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

stk_disp_examplewelcome;


%% DEFINE TEST FUNCTIONS

if ~ exist ('TESTCASE_NUM', 'var')
    % Default: use the first test case
    TESTCASE_NUM = 1;
end

SHOW1DSAMPLEPATHS = true;

switch TESTCASE_NUM
    case 1, %
        DIM = 1;
        BOX = [-1.0; 1.0];
        f   = @(x)((0.8*x-0.2).^2+1.0*exp(-1/2*(abs(x+0.1)/0.1).^1.95)+exp(-1/2*(2*x-0.6).^2/0.1)-0.02);
        
        NT = 400;
        xt = stk_sampling_regulargrid (NT, DIM, BOX);
        zt = stk_feval (f, xt);
        
        xi_ind = [90 230 290 350];
        xi = xt(xi_ind, :);
        
        CRIT = 'IAGO';
        NOISE = 'simulatenoise';
        noisevariance =  0.1^2;
    case 2
        DIM = 2;
        BOX = [[-1; 1], [-1; 1]];
        
        f_ = inline ('exp(1.8*(x1+x2)) + 3*x1 + 6*x2.^2 + 3*sin(4*pi*x1)', 'x1', 'x2');
        f  = @(x)(-f_(x(:, 1), x(:, 2)));
        
        NT = 400; % nb of points in the grid
        xt = stk_sampling_regulargrid (NT, DIM, BOX);
        zt = stk_feval (f, xt);
        
        NI = 4;
        xi = stk_sampling_maximinlhs (NI, DIM, BOX);
        
        CRIT = 'IAGO';
        NOISE = 'simulatenoise';
        noisevariance =  2^2;
end

%% PARAMETERS OF THE OPTIMIZATION PROCEDURE
maxiter = 50;

options = {};

if exist('NOISE', 'var')
    options = [options {'noise', NOISE}];
    options = [options {'noisevariance', noisevariance}];
end

if exist('xg', 'var')
    options = [options {'searchgrid_xvals', xg}];
end

if exist('model', 'var')
    options = [options {'model', model}];
    options = [options {'estimparams', false}];
end

if exist('CRIT', 'var')
    options = [options {'samplingcritname', CRIT}];
end

if DIM  <= 2 && exist('zt', 'var')
    options = [options {'disp', true, ...
        'disp_xvals', xt, ...
        'disp_zvals', zt}];
end

if exist('SHOW1DSAMPLEPATHS', 'var')
    options = [options {'show1dsamplepaths', SHOW1DSAMPLEPATHS}];
end

options = [options {'pause', false}];


%% ACTUAL OPTIMIZATION
res = stk_optim(f, DIM, BOX, xi, maxiter, options);

%[xi, zi, xstarn, Mn] = stk_optim(f, DIM, BOX, xi, maxiter, 'samplingcrit', 'EI', 'disp1d', true);