% STK_EXAMPLE_MISC01  Several correlation functions from the Matern family
%
% The Matern 1/2 correlation function is also known as the "exponential correla-
% tion function". This is the correlation function of an Ornstein-Ulhenbeck pro-
% cess.
%
% The Matern covariance function tends to the Gaussian correlation function when
% its regularity (smoothness) parameter tends to infinity.
%
% See also: stk_materncov_iso, stk_materncov_aniso

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

stk_disp_examplewelcome;  stk_figure ('stk_example_misc01');


%% List of correlation functions

SIGMA2 = 1.0;  % variance parameter
RHO1   = 1.0;  % scale (range) parameter

% kriging with constant mean function (ordinary kriging)
list_cov = {...
    'Matern 1/2', 'stk_materncov_iso',   log([SIGMA2; 0.5; 1/RHO1]); ...
    'Matern 3/2', 'stk_materncov32_iso', log([SIGMA2;      1/RHO1]); ...
    'Matern 5/2', 'stk_materncov52_iso', log([SIGMA2;      1/RHO1]); ...
    'Matern 8.0', 'stk_materncov_iso',   log([SIGMA2; 8.0; 1/RHO1]); ...
    'Gaussian',   'stk_gausscov_iso',    log([SIGMA2;      1/RHO1])  };

NB_COVARIANCE_FUNCTIONS = size (list_cov, 1);


%% Visualisation

x1 = 0.0;
x2 = stk_sampling_regulargrid (1000, 1, [-5; 5]);

col = {'r', 'b', 'g', 'k', 'm--'};

for j = 1:NB_COVARIANCE_FUNCTIONS,
    covfun = list_cov{j, 2};
    param = list_cov{j, 3};
    plot (x2, feval (covfun, param, x1, x2 ), col{j});
    hold on;
end

stk_labels ('x', 'correlation r(x)');  legend (list_cov{:, 1});
stk_title ('Some members of the Matern family');


%!test stk_example_misc01;  close all;
