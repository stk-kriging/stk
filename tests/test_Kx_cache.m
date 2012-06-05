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

%% parameters of the test

n = 20; % 10 observations + 10 predictions
d = 1;  % dimension of the input space

x0 = stk_sampling_cartesiangrid(n, d, [0; pi]);

idx_obs = 1:2:n;
idx_prd = 2:2:n;

x_obs = struct('a', x0.a(idx_obs));
z_obs = stk_feval(@sin, x_obs);
x_prd = struct('a', x0.a(idx_prd));

COVARIANCE_TYPE = 'stk_materncov32_iso';


%% method 1: direct use of stk_predict

model = stk_model(COVARIANCE_TYPE);

y_prd1 = stk_predict(model, x_obs, z_obs, x_prd);


%% method 2: use of Kx_cache

model = stk_model(COVARIANCE_TYPE);
[model.Kx_cache, model.Px_cache] = stk_make_matcov(model, x0);

y_prd2 = stk_predict(model, idx_obs, z_obs, idx_prd);


%% check that both methods give the same result

assert(isequal(y_prd1, y_prd2));
