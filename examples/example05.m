% Example 05 generates conditioned sample paths
% =============================================
%    Generate conditioned sample paths.

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%

%% Welcome

disp('                  ');
disp('#================#');
disp('#   Example 05   #');
disp('#================#');
disp('                  ');


%% Define a 1d test function

f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space
box = [-1.0; 1.0];                              % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_cartesiangrid( NT, DIM, box );
zt = stk_feval( f, xt );


%% Generate observations
%
% The objective is to construct an approximation of f and to simulate
% conditioned sample paths from NI observations. The observation locations
% are chosen as a subset of xt.a.
%

NI = 6;                               % nb of evaluations that will be used
xi_ind  = [1 20 90 200 300 350];      %
xi.a = xt.a(xi_ind, 1);
zi = stk_feval( f, xi );              % evaluation results


%% Specification of the model
%
% We choose a Matern covariance with "fixed parameters" (in other
% words, the parameters of the covariance function are provided by the user
% rather than estimated from data).
%

% The following line defines a model with a constant but unknown mean
% (ordinary kriging) and a Matern covariance function. (Some default
% parameters are also set, but we override them below.)
model = stk_model('stk_materncov_iso');

% Parameters for the Matern covariance
% ("help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter
model.param = log([SIGMA2; NU; 1/RHO1]);


%% Carry out the kriging prediction and generate conditional sample paths
%

% Carry out the kriging prediction at points xt.a
[zp, lambda] = stk_predict( model, xi, zi, xt );

% Generate (unconditional) sample paths according to the model
NB_PATHS = 10;
zsim = stk_generate_samplepaths( model, xt, NB_PATHS );

% Condition sample paths on the observations
zsimc = stk_conditionning( lambda, zi, zsim, xi_ind );

% Display the result
stk_plot1dsim ( xi, zi, xt, zt, zp, zsimc );
t = 'Kriging prediction and conditional sample paths';
set( gcf, 'Name', t ); title(t);
xlabel('x'); ylabel('z');
