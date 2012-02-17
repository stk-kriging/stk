% Example 03 constructs a kriging approximation in 2D
% ==================================================
%    Construct a kriging approximation in 2D. In this example, the model is
%    estimated from data.

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version:   1.0
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
disp('#   Example 03   #');
disp('#================#');
disp('                  ');


%% Definition of a 2D test function

% define a 2D test function
f_ = inline('exp(1.8*(x1+x2))+3*x1+6*x2.^2+3*sin(4*pi*x1)', 'x1', 'x2');
f  = @(x)(f_(x(:,1), x(:,2)));
DIM = 2;
NG = 60;

XG = linspace(-1, 1, NG)';
[XX, YY] = meshgrid(XG);
ZZ = f_(XX, YY);
% ... and plot it on a grid
figure(1);
subplot(2, 2, 1);
surf(XX, YY, ZZ);
title('function to be approximated')

% In STK, the inputs and outputs are members of a structure array
% The field 'a' is used to store the numerical values
nt = NG * NG;
xt.a = [reshape(XX,nt,1), reshape(YY,nt,1)]; % nt x DIM,
zt.a = reshape(ZZ,nt,1);                     % nt x 1


%% To run STK, choose a covariance structure
% Some examples given below

COVSTRUCT = 1 ; % 1: Matern anisotropic covariance, with unknown
%    constant mean, without noise
% 2: Matern anisotropic covariance, with unknown
%    constant mean, with noise
% 3: Matern anisotropic covariance, with unknown
%    polynomial mean of degree 2, without noise

switch COVSTRUCT
    case 1
        COVNAME  = 'stk_materncov_aniso';
        COVORDER = 0; % degree of the polynomial mean
        SIGMA2   = 3;
        NU       = 4;
        RHO1     = 0.1;
        RHO2     = 0.1;
        PARAM0   = log([SIGMA2; NU; 1/RHO1; 1/RHO2]);
        
    case 2
        COVNAME  = 'stk_materncov_aniso';
        COVORDER = 0;
        SIGMA2   = 3;
        NU       = 4;
        RHO1     = 0.1;
        RHO2     = 0.1;
        PARAM0   = log([SIGMA2; NU; 1/RHO1; 1/RHO2]);
        NOISEVARIANCE = 1e0;  %% here we add some observation noise
        
    case 3
        COVNAME  = 'stk_materncov_aniso';
        COVORDER = 2;
        SIGMA2   = 3;
        NU       = 4;
        RHO1     = 0.1;
        RHO2     = 0.01;  %% shorter range for the second input variable
        PARAM0   = log([SIGMA2; NU; 1/RHO1; 1/RHO2]);
        
end

model = stk_model(COVNAME, DIM);
model.order = COVORDER;
model.param = PARAM0;

if exist('NOISEVARIANCE', 'var')
    model.lognoisevariance = log(NOISEVARIANCE);
    % FIXME : provide an example with options.noiseopt=1;
end


%% generate a random space-filling design

NI = 36;
xi = stk_sampling_maximinlhs(NI, DIM, [[-1 -1];[1 1]]);
zi = stk_feval (f, xi);
if exist('NOISEVARIANCE', 'var')
    zi.a = zi.a + randn(size(zi.a))*sqrt(NOISEVARIANCE);
end


%% estimate the parameters of the covariance

model.param = stk_param_estim(PARAM0, xi, zi, model);


%% carry out kriging prediction

zp = stk_predict(xi, zi, xt, model);


%% display results

figure(1)
subplot(2,2,2)
surf(XX,YY,reshape(zp.a,NG,NG));
tsc = sprintf('approximation from %d points', NI);
hold on
plot3(xi.a(:,1), xi.a(:,2), zi.a, 'ro','MarkerFaceColor','r');
hold off
title(tsc);
subplot(2,2,3)
surf(XX,YY,reshape(abs(zp.a-zt.a),NG,NG));
hold on
plot3(xi.a(:,1), xi.a(:,2), 1.0*ones(size(zi.a)), 'ro','MarkerFaceColor','r');
hold off
title('approximation error');
