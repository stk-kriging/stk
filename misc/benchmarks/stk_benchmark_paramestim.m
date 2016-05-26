% STK_BENCHMARK_PARAMESTIM  A simple 1D parameter estimation benchmark

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function stk_benchmark_paramestim ()

NREP = 20;

for noise_std = [0 0.1],
    for ni = [10 50],
        
        t = zeros (1, NREP + 1);
        
        for i = 1:(NREP + 1),
            tic;
            test_function (ni, noise_std);
            t(i) = toc;
        end
        
        t = t(2:end);
        
        fprintf ('noise_std = %.1f  ', noise_std);
        fprintf ('ni = %d  ', ni);
        
        t_est = median (t);
        t_mad = mean (abs (t - t_est));
        fprintf ('t = %.3f [%.3f]\n', t_est, t_mad);
        
        drawnow ();
    end
end

end


function test_function (ni, noise_std)

f = @(x)(- (0.8 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
DIM = 1;               % Dimension of the factor space
BOX = [-1.0; 1.0];     % Factor space

NOISY = (noise_std > 0);

NITER = 5;  % number of random designs generated in stk_sampling_maximinlhs()
xi = stk_sampling_maximinlhs (ni, DIM, BOX, NITER);  % evaluation points

zi = stk_feval (f, xi);  % evaluation results

if NOISY,
    zi = zi + noise_std * randn (ni, 1);
end

model = stk_model ('stk_materncov_iso');

if ~ NOISY,
    % Noiseless case: set a small "regularization" noise
    % the (log)variance of which is provided by stk_param_init
    model.lognoisevariance = 1e-10;
else
    % Otherwise, set the variance of the noise
    % (assumed to be known, not estimated, in this example)
    model.lognoisevariance = 2 * log (noise_std);
end

% Estimate the parameters
model.param = stk_param_estim (model, xi, zi, log ([1.0; 4.0; 1/0.4]));

end
