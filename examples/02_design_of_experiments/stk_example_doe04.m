% STK_EXAMPLE_DOE04  Probability of misclassification
%
% The upper panel shows posterior means and variances as usual, and the
% threshold of interest, which is at T = 0.85 (dashed line).
%
% The lower panel shows the probability of misclassification as a function of x
% (blue curve), i.e., the probability that the actual value of the function is
% not on the same side of the threshold as the prediction (posterior mean).
%
% We also plot the expected future probability of misclassification (magenta
% curve), should a new evaluation be made at x = 3.
%
% Note that both probabilities are obtained using stk_pmisclass.

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

stk_disp_examplewelcome;  stk_figure ('stk_example_doe04');

T = 0.85;

f = @sin;          % test function
DIM = 1;           % dimension of the factor space
BOX = [0.0; 3.0];  % factor space

x_obs = stk_dataframe ([0 0.2 0.4 1.5 2.0]', {'x'});
z_obs = stk_feval (f, x_obs);

n = 400;
x = stk_sampling_regulargrid (n, DIM, BOX);  x.colnames = {'x'};
z = stk_feval (f, x);

model = stk_model ('stk_materncov52_iso');
model.param = log ([0.1 0.8]);


%% Current probability of misclassification
%
% Here we plot the CURRENT probability of misclassification of the response with
% respect to the threshold T---i.e., the probability of misclassification given
% the available data (x_obs, z_obs).

z_pred = stk_predict (model, x_obs, z_obs, x);

pmisclass = stk_pmisclass (T, z_pred);

subplot (2, 1, 1);  stk_plot1d (x_obs, z_obs, x, z, z_pred);
hold on;  plot (xlim, T * [1 1], 'k--');

subplot (2, 1, 2);  plot (x, pmisclass);
ylim ([0; 0.5]);  stk_ylabel ('pmisclass');


%% Expected future probability of misclassification
%
% Now we plot the EXPECTED FUTURE probability of misclassification for an
% additional evaluation at xnew---i.e, the expectation of the probability of
% misclassification given the available data (x_obs, z_obs) and the future
% response (x_new, f(x_new)). Teh expectation is taken with respect to the
% unknown future response f(x_new).

xnew = 3.0;  % Location of the next evaluation

[z_pred, ignore_lambda, ignore_mu, Kpost_all] = ...
    stk_predict (model, x_obs, z_obs, [x; xnew]);
% Note: in recent versions of Octave or Matlab, you can use ~ to
% ignore unwanted output arguments

xihat_xt = z_pred(1:n, :);

K12 = Kpost_all(1:n, end);  % Posterior covariance between locations x and x_new
K22 = Kpost_all(end, end);  % Posterior variance at xnew

expected_pmisclass = stk_pmisclass (T, xihat_xt, K12, K22);

hold on; plot (x, expected_pmisclass, 'm');

legend ('current pmisclass', 'expected pmisclass', 'Location', 'SouthWest')

%!test stk_example_doe04;  close all;
