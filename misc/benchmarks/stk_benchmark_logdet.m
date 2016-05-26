% STK_BENCHMARK_LOGDET1

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
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

% NREP = 1000; n = 20; % test on small matrices
NREP = 100; n = 200; % test on large matrices

d = 2;
x = stk_sampling_maximinlhs (n, d, [], 10);
model = stk_model ('stk_materncov52_aniso', d);
model.param = zeros (size (model.param));

propname = {                       ...
    'log_det_covariance_matrix_a', ...
    'log_det_covariance_matrix_b', ...
    'log_det_covariance_matrix_c', ...
    'log_det_covariance_matrix_d', ...
    'log_det_covariance_matrix_e'  };

L = length (propname);
t = zeros (L, 1);
v = zeros (L, 1);

for k = 1:L
    fprintf ('Method %d/%d: %s...', k, L, propname{k});
    tic;
    for i = 1:NREP,
        kreq = stk_kreq_qr (model, x);
        logdet = get (kreq, propname{k});
    end
    t(k) = toc / NREP;
    v(k) = logdet;
    fprintf ('\n');
end

display (t)
display (v)
