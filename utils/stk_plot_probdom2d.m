% STK_PLOT_PROBDOM2D represents the uncertainty about a 2D Pareto
%
% CALL: stk_plot_probdom2d (MODEL1, MODEL2, BOX)
%
%    represents the uncertainty about the 2D Pareto front associated with the
%    minimization of models MODEL1 and MODEL2 over the domain BOX.
%
%    Use prior model structures (see stk_model) to represent prior uncertainty.
%
%    Use @stk_model_gpposterior objects to represent posterior uncertainty.
%
% EXPERIMENTAL FUNCTION WARNING
%
%    This function is currently considered experimental.  Because of the very
%    basic method used to choose the simulation points (uniform IID sampling),
%    the plots produced by this function are very unreliable representations
%    on the residual uncertainty on the Pareto front (except perhaps on low-
%    dimensional problems of moderate difficulty).
%
%    STK users that wish to experiment with it are welcome to do so, but should
%    be aware of this limitation.  We invite them to direct any questions,
%    remarks or comments about this experimental class to the STK mailing list.
%
% REFERENCE
%
%  [1] Michael Binois, David Ginsbourger and Olivier Roustant,  Quantifying
%      uncertainty on Pareto fronts with Gaussian Process conditional simu-
%      lations,  European J. of Operational Research, 2043(2):386-394, 2015.
%
% See also: stk_example_misc04, stk_model, stk_gpposterior

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function stk_plot_probdom2d (model1, model2, box)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% FIXME: Provide a convenient way of changing these parameters

% Number of additional random points in input space
NB_SIMULATION_POINTS = 1000;

% Number of sample paths drawn to estimate the probabilities
NB_SAMPLEPATHS = 100;

% Number of individual sample paths to be plotted
% (must be smaller than NB_SAMPLEPATHS)
NB_SAMPLEPATHS_PLOT = 20;

% Number of test points in the objective space
NB_TEST_POINTS = 100 ^ 2;


%% Observation points (points where both objectives hae been evaluated)

x1 = double (get_input_data (model1));
x2 = double (get_input_data (model2));

x_obs = intersect (x1, x2, 'rows');


%% Simulation points

x_sim = stk_sampling_randunif (NB_SIMULATION_POINTS, [], box);
x_sim = vertcat (x_sim, x_obs);

% FIXME: Optimize the location of simulation points... (IID uniform is perhaps
%    approximately OK for vague prior models, but *not* for posterior models
%    obtained at the end of a long optimization procedure...)


%% Generate a "large" number of sample paths

% Simulate samplepaths
y1_sim = double (stk_generate_samplepaths (model1, x_sim, NB_SAMPLEPATHS));
y2_sim = double (stk_generate_samplepaths (model2, x_sim, NB_SAMPLEPATHS));

% Empirical lower/upper bounds for each response
y1_min = min (y1_sim(:));  y1_max = max (y1_sim(:));
y2_min = min (y2_sim(:));  y2_max = max (y2_sim(:));

% Axis for a nice plot
y1_axis = [y1_min - 0.05 * (y1_max - y1_min), y1_max];
y2_axis = [y2_min - 0.05 * (y2_max - y2_min), y2_max];


%% Plot a few individual sample paths of the Pareto front

stk_subplot (1, 2, 1);  cm = jet (NB_SAMPLEPATHS_PLOT);

for i = 1:NB_SAMPLEPATHS_PLOT
    
    % Extract Pareto front
    y_sim = [y1_sim(:, i) y2_sim(:, i)];
    y_nd = y_sim(stk_paretofind (y_sim), :);
    
    % Add two extremities to the Pareto front
    y_nd = [[y_nd(1, 1) y2_max]; y_nd; [y1_max y_nd(end, 2)]];
    
    stairs (y_nd(:, 1), y_nd(:, 2), 'Color', cm(i, :));
    
    stk_labels ('first objective', 'second objective');
    % FIXME: Add meaningful labels in a 'robust' way... currently, prior model
    %        structures do not necessarily have a 'response_name' field, and
    %        for posterior model object the 'response_name' field is not
    %        directly accessible...
    
    if i == 1
        axis ([y1_axis y2_axis]);  hold on;
    end
end

stk_title ('simulated Pareto fronts');


%% Probability of being dominated

% Test points (a grid over the relevant subset of the objective space)
y_test = stk_sampling_regulargrid (NB_TEST_POINTS, 2, [y1_axis' y2_axis']);

% Compute empirical probabilities
isdom = zeros (size (y_test, 1), 1);
for i = 1:NB_SAMPLEPATHS
    y_sim = [y1_sim(:, i) y2_sim(:, i)];
    isdom = isdom + stk_isdominated (y_test, y_sim);
end
isdom = isdom / NB_SAMPLEPATHS;

% Figure
stk_subplot (1, 2, 2);
colormap (hot);  pcolor (y_test, isdom);
colorbar ('YTick', [0 .25 .5 .75 1], ...
    'YTickLabel', {'0%', '25%', '50%', '75%', '100%'});
stk_labels ('first objective', 'second objective');  % FIXME: See above
stk_title ('Proba. of being dominated');

% FIXME: Change the aspect ratio of the figure, if it is possible to do it in
%        a portable way.  Figures with 1 x 2 subplots are not pretty...

end % function


%#ok<*AGROW>
