% Example 02 constructs a kriging approximation in 1D
% ===================================================
%    Construct a kriging approximation in 1D. In this example, the model is
%    estimated from data.

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


%% Define a 1d test function (the same as in example01.m)

f = @(x)( -(0.8*x+sin(5*x+1)+0.1*sin(10*x)) );  % define a 1D test function
DIM = 1;                                        % dimension of the factor space
box = [-1.0; 1.0];                              % factor space

NT = 400; % nb of points in the grid
xt = stk_sampling_cartesiangrid( NT, DIM, box );
zt = stk_feval( f, xt );

%% Generate a random sampling plan
%
% The objective is to construct an approximation of f with a budget of NI
% evaluations performed on a randomly generated (uniform) design.
%
% Change the value of NOISEVARIANCE to add a Gaussian evaluation noise on
% the observations.
%

NOISEVARIANCE = 0;

NI = 6;                                     % nb of evaluations that will be used
xi = stk_sampling_randunif(NI, DIM, box);   % evaluation points
zi = stk_feval(f, xi);                      % evaluation results

if NOISEVARIANCE > 0,
    zi.a = zi.a + sqrt(NOISEVARIANCE) * randn(NI,1);
    % (don't forget that the data is in the ".a" field!)
end


%% Specification of the model
%
% We choose a Matern covariance, the parameters of which will be estimated from the data.
%
% The values of the parameters that are provided here, including the noise variance, are
% only used as an initial point for the optimization algorithm used in stk_param_estim().
%

% Parameters for the Matern covariance (see "help stk_materncov_iso" for more information)
SIGMA2 = 1.0;  % variance parameter
NU     = 4.0;  % regularity parameter
RHO1   = 0.4;  % scale (range) parameter

% Specification of the model (see "help stk_model" for more information)
model.covariance_type  = 'stk_materncov_iso';     % isotropic Matern covariance function
model.order = 0;                                  % ordinary kriging (i.e., constant mean)
model.param = [log(SIGMA2),log(NU),log(1/RHO1)]'; % vector of parameters

% Noise variance
if NOISEVARIANCE > 0,
    model.lognoisevariance = log( 3 * NOISEVARIANCE );
    % (this is not the true value of the noise variance !)
else
    % Even if we don't assume that the observations are noisy,
    % it is wiser to add a small "regularization noise".
    model.lognoisevariance = log( 100 * eps );
end

%% Estimatation the parameters of the covariance
%
% The parameters are estimated by the REML (REstricted Maximum Likelihood) method.
%

model.param = stk_param_estim( model.param, xi, zi, model);

%% carry out kriging prediction

zp = stk_predict(xi, zi, xt, model);

%% display results

stk_plot1d(xi,zi,xt,zt,zp)
model %#ok<NOPTS>
