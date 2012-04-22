% Example 01 constructs a kriging approximation in 1D
% ===================================================
%    Construct a kriging approximation in 1D. In this example, the model is
%    fixed by the user.

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
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

clear all; close all;

f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space  
box = [-1.0; 1.0];                              % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_cartesiangrid( NT, DIM, box );
zt = stk_feval( f, xt );

figure(1); set( gcf, 'Name', 'Plot of the function to be approximated');
plot( xt.a, zt.a ); xlabel('x'); ylabel('z');

% In STK, the inputs and outputs are members of a structure array
% The field 'a' is used to store the numerical values 


%% Generate a space-filling design
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a "space-filling design".
%
% A regular grid (i.e., a grid with constant spacing) is constructed using
% stk_sampling_cartesiangrid(), which is equivalent to linspace() in this
% 1d example.
%

NI = 6;                                         % nb of evaluations that will be used 
xi = stk_sampling_cartesiangrid( NI, DIM, box); % evaluation points
zi = stk_feval( f, xi );                        % evaluation results


%% Specification of the model
%
% We choose a Matern covariance with "fixed parameters" (in other 
% words, the parameters of the covariance function are provided by the user
% rather than estimated from data).
%

% Parameters for the Matern covariance ("help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter

% Specification of the model (see "help stk_model" for more information)
model.covariance_type  = 'stk_materncov_iso';     % isotropic Matern covariance function
model.order = 0;                                  % ordinary kriging (i.e., constant mean)
model.param = [log(SIGMA2),log(NU),log(1/RHO1)]'; % vector of parameters


%% Carry out the kriging prediction and display the result
%
% The result of a kriging predicition is provided by stk_predict() in a
% structure, called "zp" in this example, which has two fields: "zp.a" (the
% kriging mean) and "zp.v" (the kriging variance).
%

% Carry out the kriging prediction at points xt.a
zp = stk_predict( xi, zi, xt, model );

% Display the result
stk_plot1d( xi, zi, xt, zt, zp );
t = 'Kriging prediction based on noiseless observations';
set( gcf, 'Name', t ); title(t);
xlabel('x'); ylabel('z');


%% Repeat the experiment in a noisy setting

NOISEVARIANCE = (1e-1)^2;

% Now the observations are perturbed by an additive Gaussian noise
noise = sqrt(NOISEVARIANCE) * randn(size(zi.a));
zi_n = struct( 'a', zi.a + noise  );

% We also include the observation noise in the model
model_n = model;
model_n.lognoisevariance = log(NOISEVARIANCE);

% Carry out the kriging prediction at locations xt.a
zp_n = stk_predict( xi, zi_n, xt, model_n );

% Display the result
stk_plot1d( xi, zi_n, xt, zt, zp_n );
t = 'Kriging prediction based on noisy observations';
set( gcf, 'Name', t ); title(t);
xlabel('x'); ylabel('z');