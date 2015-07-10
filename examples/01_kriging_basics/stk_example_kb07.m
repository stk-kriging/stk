% STK_EXAMPLE_KB07  Simulation of sample paths from a Matern process

% Copyright Notice
%
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

stk_disp_examplewelcome;  stk_figure ('stk_example_kb07');


%% Define the factor space & a Matern GP model on it

% Factor space
DIM = 1;
BOX = [-1.0; 1.0];

% Grid
N = 400;
x = stk_sampling_regulargrid (N, DIM, BOX);

% Model
model  = stk_model ('stk_materncov_iso');
SIGMA2 = 1.0;  % variance parameter
NU     = NaN;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
model.param = log ([SIGMA2; NU; 1/RHO1]);

% Several values for nu
nu_list = [0.5 1.5 2.5 10.0];


%% Generate (unconditional) sample paths

NB_PATHS = 10;

for k = 1:4,
    
    model.param(2) = log (nu_list(k));
    
    zsim = stk_generate_samplepaths (model, x, NB_PATHS);
    
    % Display the result
    stk_subplot (2, 2, k);  plot (x, zsim, 'LineWidth', 2);  legend off;
    stk_title (sprintf ('Matern, nu = %.1f', nu_list(k)));
    stk_labels ('input variable x', 'response z', 'FontWeight', 'bold');
    
end


%!test stk_example_kb07;  close all;
