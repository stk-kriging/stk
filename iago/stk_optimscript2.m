
DIM = 1;
BOX = stk_hrect ([-1.0; 1.0], {'x'});

f0 = @(x)(- (x - 1) .^2 );

NOISEVARIANCE = 1 ^ 2;

% Candidate points for the optimization
nc = 31;
xc = stk_sampling_regulargrid (nc, DIM, BOX);

% Initial DoE
xi = xc(1:5:nc);

% Ground truth  (this gid of 400 is not actually used by the algorithm)
NT = 400;
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f0, xt);

% Optimise f0 based on noisy evaluations
%   (homoscedastic Gaussian noise)
f = @(x)(f0(x) + sqrt (NOISEVARIANCE) * randn (size (x)));


%% Parameters of the optimization procedure

% Maximum number of iterations
MAX_ITER = 100;

% Use IAGO unless instructed otherwise
options = {'samplingcritname', 'IAGO'};

% Homoscedastic noise, known noise variance
options = [options {'noisevariance', NOISEVARIANCE}];

% Activate display (figures) and provide ground truth
options = [options { ...
    'disp', true, 'show1dsamplepaths', true, ...
    'disp_xvals', xt, 'disp_zvals', zt}];

% Do not pause (set this to true if you want time to look at the figures)
options = [options {'pause', false}];

options = [options {...
    'searchgrid_xvals', xc, ...
    'nsamplepaths', 500}];


%% Optimization

[x_opt, f_opt, ~, aux] = stk_optim (f, DIM, BOX, xi, MAX_ITER, options);
