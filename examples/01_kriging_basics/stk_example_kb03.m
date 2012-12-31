% Example 03 constructs a kriging approximation in 2D
% ==================================================
%    Construct a kriging approximation in 2D. In this example, the model is
%    estimated from data.

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

stk_disp_examplewelcome();

CONTOUR_LINES = 40; % number of levels in contour plots
DOT_STYLE = {'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4};


%% CHOICE OF A TWO-DIMENSIONAL TEST FUNCTION

CASENUM = 1;

switch CASENUM
    
    case 1,  % the classical BRANIN-HOO test function
        f = @stk_testfun_braninhoo;
        DIM = 2;
        BOX = [[-5; 10], [0; 15]];
        NI = 20;

    case 2,  % another test function
        f_ = inline(['exp(1.8*(x1+x2)) + 3*x1 + 6*x2.^2' ...
		      '+ 3*sin(4*pi*x1)'], 'x1', 'x2');
        f  = @(x)(f_(x(:,1), x(:,2)));
        DIM = 2;
        BOX = [[-1; 1], [-1; 1]];
        NI = 40; % this second function is much harder to approximate
        
end


%% COMPUTE AND VISUALIZE THE FUNCTION ON A 80 x 80 REGULAR GRID

% Size of the regular grid
NT = 80^2;

% The function stk_sampling_regulargrid() does the job of creating the grid
xt = stk_sampling_regulargrid(NT, DIM, BOX);

% Compute the corresponding responses (stored in zt.a)
zt = struct('a', f(xt.a));

% Since xt is a regular grid, we can do a contour plot
figure; h1 = subplot(2, 2, 1); stk_plot2d(@contour, xt, f, CONTOUR_LINES);
axis(BOX(:)); title('function to be approximated');


%% CHOOSE A KRIGING (GAUSSIAN PROCESS) MODEL

% We start with a generic (anisotropic) Matern covariance function.
model = stk_model('stk_materncov_aniso', DIM);

% As a default choice, a constant (but unknown) mean is used.
% model.randomprocess.priormean = stk_lm('affine');    % UNCOMMENT: AFFINE TREND
% model.randomprocess.priormean = stk_lm('quadratic'); % UNCOMMENT: "FULL QUADRATIC" TREND

% Good practice: add a small "regularization noise" (nugget)
MODEL_NOISE_STD = 1e-5;
model.noise.cov = stk_homnoisecov(MODEL_NOISE_STD^2);


%% EVALUATE THE FUNCTION ON A "MAXIMIN LHS" DESIGN

xi = stk_sampling_maximinlhs(NI, DIM, BOX);
zi = stk_feval(f, xi);

% Simulate noisy evaluations (optional)
TRUE_NOISE_STD = 0;
if TRUE_NOISE_STD > 0
    zi.a = zi.a + randn(size(zi.a)) * TRUE_NOISE_STD;
end

% Add the design points to the first plot
hold on; plot(xi.a(:,1), xi.a(:,2), DOT_STYLE{:});


%% ESTIMATE THE PARAMETERS OF THE COVARIANCE FUNCTION

model = stk_setobs(model, stk_makedata(xi, zi));

% % Initial guess for the parameters of the Matern covariance
% param0 = stk_param_init(model, BOX);

% Alternative: user-defined initial guess for the parameters of the Matern covariance
% (see "help stk_materncov_aniso" for more information)
SIGMA2 = var(zi.a);
NU     = 2;
RHO1   = (BOX(2,1) - BOX(1,1)) / 10;
RHO2   = (BOX(2,2) - BOX(1,2)) / 10;
param0 = log([SIGMA2; NU; 1/RHO1; 1/RHO2]);

model.randomprocess.priorcov.param = stk_param_estim(model, param0);


%% CARRY OUT KRIGING PREDICITION AND VISUALIZE

% Here, we compute the kriging prediction on each point of the grid
zp = stk_predict(model, xt);

% Display the result using a contour plot, to be compared with the contour
% lines of the true function
h2 = subplot(2, 2, 2); stk_plot2d(@contour, xt, zp, CONTOUR_LINES);
tsc = sprintf('approximation from %d points', NI); hold on;
plot(xi.a(:,1), xi.a(:,2), DOT_STYLE{:});
hold off; axis(BOX(:)); title(tsc);


%% VISUALIZE THE ACTUAL PREDICTION ERROR AND THE KRIGING STANDARD DEVIATION

h3 = subplot(2, 2, 3); stk_plot2d(@pcolor, xt, log(abs(zp.a - zt.a)));
hold on; plot(xi.a(:,1), xi.a(:,2), DOT_STYLE{:});
hold off; axis(BOX(:)); title('true approx error (log)');

h4 = subplot(2, 2, 4); stk_plot2d(@pcolor, xt, 0.5 * log(zp.v));
hold on; plot(xi.a(:,1), xi.a(:,2), DOT_STYLE{:});
hold off; axis(BOX(:)); title('kriging std (log)');
