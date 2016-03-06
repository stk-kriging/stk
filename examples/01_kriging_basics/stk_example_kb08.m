% STK_EXAMPLE_KB08  Generation of conditioned sample paths made easy
%
% It has been demonstrated, in stk_example_kb05, how to generate conditioned
% sample paths using unconditioned sample paths and conditioning by kriging.
%
% This example shows how to do the same in a more concise way, letting STK
% take care of the details.

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb08');

NB_PATHS = 10;  % number of sample paths that we want to produce


%% Dataset

% Load a 1D noiseless dataset
[xi, zi, ref] = stk_dataset_twobumps ('noiseless');

% The grid where predictions must be made
xt = ref.xt;

% Reference values on the grid
zt = ref.zt;

% Indices of the evaluation points xi in the grid
xi_ind = ref.xi_ind;


%% Specification of the model

model = stk_model ('stk_materncov_iso');

% Parameters for the Matern covariance
% ("help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
model.param = log ([SIGMA2; NU; 1/RHO1]);


%% Method 1: explicit conditioning by kriging (as in stk_example_kb05)

zsim = stk_generate_samplepaths (model, xt, NB_PATHS);

% Carry out the kriging prediction at points xt
[zp, lambda] = stk_predict (model, xi, zi, xt);

% Condition sample paths on the observations
zsimc1 = stk_conditioning (lambda, zi, zsim, xi_ind);


%% Method 2: let STK take care of the details

zsimc2 = stk_generate_samplepaths (model, xi, zi, xt, NB_PATHS);


%% Figure

stk_subplot (1, 2, 1); plot (xt, zsimc1, 'LineWidth', 2);  legend off;  hold on;
plot (xi, zi, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
stk_title (sprintf ('%d conditional sample paths', NB_PATHS));
stk_labels ('input variable x', 'response z');

stk_subplot (1, 2, 2); plot (xt, zsimc2, 'LineWidth', 2);  legend off;  hold on;
plot (xi, zi, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
stk_title (sprintf ('another set of %d sample paths', NB_PATHS));
stk_labels ('input variable x', 'response z');


%!test stk_example_kb08;  close all;
