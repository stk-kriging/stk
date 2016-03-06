% STK_EXAMPLE_KB09  Generation of sample paths conditioned on noisy observations
%
% A Matern Gaussian process model is used, with constant but unknown mean
% (ordinary kriging) and known covariance parameters.
%
% Given noisy observations from the unknown function, a batch of conditioned
% sample paths is drawn using the "conditioning by kriging" technique
% (stk_generate_samplepaths function).
%
% See also: stk_generate_samplepaths, stk_conditioning, stk_example_kb05

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb09');


%% Example parameters

% One-dimensional test function
f = @stk_testfun_twobumps;
DIM = 1;            % Dimension of the factor space
BOX = [-1.0; 1.0];  % Factor space

% Simulation grid
NT = 400;
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f, xt);

% Default: homoscedastic noise
if ~ exist ('HOMOSCEDASTIC_NOISE', 'var')
   HOMOSCEDASTIC_NOISE = true;
end

% Standard deviation of the noise
if HOMOSCEDASTIC_NOISE
    NOISE_STD_FUNC = @(x) 0.5;
else
    NOISE_STD_FUNC = @(x) (0.1 + (x + 1) .^ 2);
end


%% Choose observation points and generate noisy observations

% Evaluate on set of locations composed of a regular grid of 30 points augmented
% with 100 point uniformly distributed on [0 0.5]
xi1 = stk_sampling_regulargrid (30, DIM, BOX);
xi2 = stk_sampling_randunif (100, DIM, [0; 1]);
xi = [xi1; xi2];

% Simulate noisy evaluations
zi = stk_feval (f, xi);                    % Noiseless evaluation results
noise_std = NOISE_STD_FUNC (xi.data);      % Standard deviation of the noise
zi = zi + noise_std .* randn (size (zi));  % Noisy evaluation results


%% Gaussian process model
%
% In this example, the variance of the noise assumed to be known beforehand.
%

model = stk_model ('stk_materncov52_iso');
model.lognoisevariance = 2 * log (noise_std);  % assumed known
model.param = stk_param_estim (model, xi, zi);


%% Generate conditional sample paths

NB_PATHS = 20;

zp = stk_predict (model, xi, zi, xt);

z_sim_cond = stk_generate_samplepaths (model, xi, zi, xt, NB_PATHS);

% Display the result
stk_plot1d (xi, zi, xt, zt, zp, z_sim_cond);  legend show;
stk_title ('Prediction and credible intervals');
stk_labels ('input variable x', 'response z');


%!test HOMOSCEDASTIC_NOISE = true;   stk_example_kb09;  close all;
%!test HOMOSCEDASTIC_NOISE = false;  stk_example_kb09;  close all;
