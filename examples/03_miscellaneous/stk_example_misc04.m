% STK_EXAMPLE_MISC04  Pareto front simulation
%
% DESCRIPTION
%
%   We consider a bi-objective optimization problem, where the objective
%   functions are modeled as a pair of independent stationary Gaussian
%   processes with a Matern 5/2 isotropic covariance function.
%
%   Figure (a): we draw (unconditional) samplepaths of the Pareto front
%   using (unconditional) samplepaths of the pair of objective functions.
%
%   Figure (b): we represent a Monte-Carlo estimate of the probability of
%   domination, computed on a grid.
%
% REFERENCE
%
%  [1] Michael Binois, David Ginsbourger and Olivier Roustant,  Quantifying
%      uncertainty on Pareto fronts with Gaussian Process conditional simu-
%      lations,  Preprint hal-00904811,  2013.

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

stk_disp_examplewelcome;


%% MODEL

DIM = 3;
BOX = repmat ([0; 1], 1, DIM);

model1 = stk_model ('stk_materncov52_iso', DIM);
model1.param = log ([1.0 1/0.5]);
model1.response_name = 'y1';

model2 = stk_model ('stk_materncov52_iso', DIM);
model2.param = log ([1.0 1/2.0]);
model2.response_name = 'y2';

NB_SIMULATION_POINTS = 500;
x_sim = stk_sampling_randunif (NB_SIMULATION_POINTS, DIM, BOX);


%% SIMULATE AND PLOT REALIZATIONS OF THE PARETO FRONT

NB_SAMPLEPATHS = 20;

% Simulate samplepaths
y1_sim = stk_generate_samplepaths (model1, x_sim, NB_SAMPLEPATHS);
y2_sim = stk_generate_samplepaths (model2, x_sim, NB_SAMPLEPATHS);

% Empirical lower/upper bounds for each response
y1_min = min (y1_sim(:));  y1_max = max (y1_sim(:));
y2_min = min (y2_sim(:));  y2_max = max (y2_sim(:));

% Axis for a nice plot
y1_axis = [y1_min - 0.05 * (y1_max - y1_min), y1_max];
y2_axis = [y2_min - 0.05 * (y2_max - y2_min), y2_max];

% Figure + colormap
stk_figure ('stk_example_misc04 (a)');
cm = jet (NB_SAMPLEPATHS);

for i = 1:NB_SAMPLEPATHS,
    
    y_sim = [y1_sim(:, i) y2_sim(:, i)];
    y_nd = y_sim(stk_paretofind (y_sim), :);

    % Add two extremities to the Pareto front
    y_nd_0 = stk_dataframe ([y_nd(1, 1) y2_max], y_nd.colnames);
    y_nd_1 = stk_dataframe ([y1_max y_nd(end, 2)], y_nd.colnames);
    y_nd = [y_nd_0; y_nd; y_nd_1];  %#ok<AGROW>
        
    stairs (y_nd(:, 1), y_nd(:, 2), 'Color', cm(i, :));
    stk_labels (model1.response_name, model2.response_name);
    axis ([y1_axis y2_axis]);  hold on;
    
end

stk_title ('Simulated Pareto fronts');


%% SIMULATE DOMINATED REGION

NB_SAMPLEPATHS = 100;

% Simulate samplepaths
y1_sim = stk_generate_samplepaths (model1, x_sim, NB_SAMPLEPATHS);
y2_sim = stk_generate_samplepaths (model2, x_sim, NB_SAMPLEPATHS);

% Empirical lower/upper bounds for each response
y1_min = min (y1_sim(:));  y1_max = max (y1_sim(:));
y2_min = min (y2_sim(:));  y2_max = max (y2_sim(:));

% Axes for a nice plot
y1_axis = [y1_min - 0.05 * (y1_max - y1_min), y1_max];
y2_axis = [y2_min - 0.05 * (y2_max - y2_min), y2_max];

% Test points
n_test = 100 ^ 2;
y_test = stk_sampling_regulargrid (n_test, 2, [y1_axis' y2_axis']);
y_test.colnames = {model1.response_name, model2.response_name};

isdom = zeros (size (y_test, 1), 1);
for i = 1:NB_SAMPLEPATHS,    
    y_sim = [y1_sim(:, i) y2_sim(:, i)];
    isdom = isdom + stk_isdominated (y_test, y_sim);   
end
isdom = isdom / NB_SAMPLEPATHS;

% Figure (b)
stk_figure ('stk_example_misc04 (b)');
colormap (hot);  stk_plot2d (@pcolor, y_test, isdom);
colorbar ('YTick', [0 .25 .5 .75 1], ...
    'YTickLabels', {'0%', '25%', '50%', '75%', '100%'});
stk_title ('Probability of domination');


%!test stk_example_misc04;  close all;
