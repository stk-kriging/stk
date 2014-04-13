% STK_EXAMPLE_KB05  Generation of conditioned sample paths made easy
%
% It has been demonstrated, in stk_exampke_kb05, how to generate conditioned
% sample paths using unconditioned sample paths and conditioning by kriging.
%
% This example shows how to do the same in a more concise way, letting STK
% take care of the details.

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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


%% Define a 1d test function, generate observations

f = @(x)(- (0.7 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
DIM = 1;            % dimension of the factor space
BOX = [-1.0; 1.0];  % factor space

NT = 400;  % nb of points in the grid
xt = stk_sampling_regulargrid (NT, DIM, BOX);
zt = stk_feval (f, xt);

xi_ind = [1 20 90 200 300 350];  % indices of evaluation points in xt
xi = xt(xi_ind, 1);              % evaluation points
zi = stk_feval (f, xi);          % evaluation results


%% Specification of the model

model = stk_model ('stk_materncov_iso');

% Parameters for the Matern covariance
% ("help stk_materncov_iso" for more information)
model.randomprocess.priorcov.sigma2 = 1.0;  % variance parameter
model.randomprocess.priorcov.nu     = 4.0;  % regularity parameter
model.randomprocess.priorcov.rho    = 0.4;  % scale (range) parameter


%% Method 1: explicit conditioning by kriging (as in stk_example_kb05)

% Set observations for the model
model_post = stk_setobs (model, xi, zi);

% FIXME: despite what the syntax suggests, this produces UNCONDITIONAL
%   sample paths at the present time. ..
zsim = stk_generate_samplepaths (model_post, xt, NB_PATHS);

% Carry out the kriging prediction at points xt
[zp_ignore, lambda] = stk_predict (model_post, xt);

% Condition sample paths on the observations
zsimc1 = stk_conditioning (lambda, zi, zsim, xi_ind);


%% Method 2: let STK take care of the details

zsimc2 = stk_generate_samplepaths (model, xi, zi, xt, NB_PATHS);

% FIXME: this currently fails because of the duplicated points in xi and xt
%   (the problem is with chol; wee also http://sourceforge.net/p/kriging/tickets/4)


%% Method 3: let STK take care of the details (bis)

% FIXME: conditioning and THEN calling stk_generate_samplepaths should
%  of cours generate conditioned sample path, as follows:

% % Set observations for the model
% model_post = stk_setobs (model, xi, zi);
% 
% zsimc3 = stk_generate_samplepaths (model_post, xt, NB_PATHS);


%% Figure

stk_subplot (1, 2, 1); plot (xt, zsimc1, 'LineWidth', 2);  legend off;  hold on;
plot (xi, zi, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
stk_title ('Conditional sample paths');
stk_labels ('input variable x', 'response z');

stk_subplot (1, 2, 2); plot (xt, zsimc2, 'LineWidth', 2);  legend off;  hold on;
plot (xi, zi, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
stk_title ('Conditional sample paths');
stk_labels ('input variable x', 'response z');


%!test stk_example_kb08;  close all;
