% STK_EXAMPLE_KB07  Simulation of sample paths from a Matern process

% Copyright Notice
%
%    Copyright (C) 2018, 2021 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

stk_disp_examplewelcome;


%% Define the factor space & a Matern GP model on it

% Factor space
DIM = 1;
BOX = [-1.0; 1.0];

% Grid
N = 400;
x = stk_sampling_regulargrid (N, DIM, BOX);

% Covariance parameters
SIGMA2 = 1.0;  % Variance parameter
NU     = 2.5;  % Regularity parameter
RHO    = 0.4;  % Scale (range) parameter

% Model
model = stk_model (@stk_materncov_iso);
model.param = log ([SIGMA2; NU; 1/RHO]);

NB_PATHS = 10;


%% Generate sample paths with different values of nu

stk_figure ('stk_example_kb07: changing nu');

nu_list = [0.5 1.5 2.5 10.0];

for k = 1:4
    
    model.param(2) = log (nu_list(k));
    model.param(3) = log (1 / RHO);
    
    zsim = stk_generate_samplepaths (model, x, NB_PATHS);
    
    % Display the result
    stk_subplot (2, 2, k);  plot (x, zsim, 'LineWidth', 2);
    stk_title (sprintf ('Matern, nu = %.1f', nu_list(k)));
    stk_labels ('input variable x', 'response z', 'FontWeight', 'bold');
    
end


%% Generate sample paths with different values of rho

stk_figure ('stk_example_kb07: changing rho');

rho_list = [0.1 0.2 0.4 0.8];

for k = 1:4
    
    model.param(2) = log (NU);
    model.param(3) = log (1 / rho_list(k));
    
    zsim = stk_generate_samplepaths (model, x, NB_PATHS);
    
    % Display the result
    stk_subplot (2, 2, k);  plot (x, zsim, 'LineWidth', 2);
    stk_title (sprintf ('Matern, rho = %.1f', rho_list(k)));
    stk_labels ('input variable x', 'response z', 'FontWeight', 'bold');
    
end


%!test stk_example_kb07;  close all;
