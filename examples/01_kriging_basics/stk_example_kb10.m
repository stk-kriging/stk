% STK_EXAMPLE_KB10  Leave-one-out (LOO) cross validation
%
% This example demonstrate the use of Leave-one-out (LOO) cross-validation to
% produced goodness-of-fit graphical diagnostics.
%
% The dataset comes from the "borehole model" response function, evaluated
% without noise on a space-filling design of size 10 * DIM = 80.  It is analyzed
% using a Gaussian process prior with unknown constant mean (with a uniform
% prior) and anisotropic stationary Matern covariance function (regularity 5/2;
% variance and range parameters estimated by restricted maximum likelihood).
%
% See also stk_predict_leaveoneout, stk_plot_predvsobs, stk_plot_histnormres

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

stk_disp_examplewelcome ();

% Define the input domain (see stk_testfun_borehole.m)
BOX = stk_hrect ([                                 ...
    0.05   100  63070  990  63.1 700 1120  9855;   ...
    0.15 50000 115600 1110 116   820 1680 12045],  ...
    {'rw', 'r', 'Tu', 'Hu', 'Tl', 'Hl', 'L', 'Kw'});

% Generate dataset
d = size (BOX, 2);
x = stk_sampling_maximinlhs (10 * d, d, BOX);   % Space-filling LHS of size 10*d
y = stk_testfun_borehole (x);                % Obtain the responses on the DoE x

% Build Gaussian process model
M_prior = stk_model (@stk_materncov52_aniso, d);  % prior
M_prior.param = stk_param_estim (M_prior, x, y);  % ReML parameter estimation

% Compye LOO predictions and residuals
[y_LOO, res_LOO] = stk_predict_leaveoneout (M_prior, x, y);

% Plot predictions VS observations (left planel)
%  and normalized residuals (right panel)
stk_figure ('stk_example_kb10 (a)');  stk_plot_predvsobs (y, y_LOO);
stk_figure ('stk_example_kb10 (b)');  stk_plot_histnormres (res_LOO.norm_res);

% Note that the three previous lines can be summarized,
% if you only need the two diagnostic plots, as:
%
%    stk_predict_leaveoneout (M_prior, x, y);
%
% (calling stk_predict_leaveoneout with no output arguments creates the plots).
