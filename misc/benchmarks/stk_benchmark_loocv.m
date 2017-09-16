% STK_BENCHMARK_LOOCV  Benchmark stk_predict_leaveoneout
%
%    Compare run time of virtual LOO-CV implementation with respect to
%    the old, "direct" implementation.
%
%    Note: correctness of implementation is already taken care of in the
%    unit tests.  We only care about computation speed here.

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function t_out = stk_benchmark_loocv ()

nrep = 100;

n = [10 20 40 80 160 320];
m = numel (n);

t_virtual = zeros (nrep, m);
t_direct = zeros (nrep, m);

for i = 1:m
    
    fprintf ('i = %d/%d...\n', i, m);
    
    % Prepare test
    d = 1;
    x_obs = stk_sampling_regulargrid (n(i), d, [0; 2*pi]);
    z_obs = stk_feval (@sin, x_obs);
    model = stk_model ('stk_materncov32_iso', d);
    model.param = log ([1; 5]);
    model.lognoisevariance = (1 + rand (n(i), 1)) * 1e-3;
    M_post = stk_model_gpposterior (model, x_obs, z_obs);
    
    testfun = @() stk_predict_leaveoneout (M_post);
    t_virtual(:, i) = stk_benchmark_ (testfun, 2, nrep);
    
    testfun = @() stk_predict_leaveoneout_direct (M_post);
    t_direct(:, i) = stk_benchmark_ (testfun, 2, nrep);
end

% Express results in ms
t_virtual = t_virtual * 1000;
t_direct = t_direct * 1000;

t = stk_dataframe (zeros (m, 4), {'virtual', '[mad]', 'direct', '[mad]'});
for i = 1:m
    t.rownames{i} = sprintf ('n = % 3d', n(i));
    t(i, 1) = median (t_virtual(:, i));
    t(i, 2) = median (abs (t_virtual(:, i) - t.virtual(i)));
    t(i, 3) = median (t_direct(:, i));
    t(i, 4) = median (abs (t_direct(:, i) - t.direct(i)));
end

if nargout == 0
    loocv_benchmark_results = t;
    display (loocv_benchmark_results);
else
    t_out = t;
end

end % function
