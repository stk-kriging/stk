% STK_BENCHMARK_PREDICT  Benchmark stk_predict

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

function t_out = stk_benchmark_predict ()

nrep = 100;

n_obs_list = [1 10 100];
n_prd_list = [1 10 100 1000];

[n_obs, n_prd] = ndgrid (n_obs_list, n_prd_list);
m = numel (n_obs);

t = zeros (nrep, m);

M_prior = test_A_init ();

for i = 1:m
    fprintf ('i = %d/%d...\n', i, m);
    testfun = @() test_A (M_prior, n_obs(i), n_prd(i));
    t(:, i) = stk_benchmark_ (testfun, 1, nrep);    
end

% Express results in ms
t = t * 1000;

t_out = stk_dataframe (zeros (m, 2), {'median', 'mad'});
for i = 1:m
    t_out.rownames{i} = sprintf ('% 4d /% 4d', n_obs(i), n_prd(i));
    t_out.median(i) = median (t(:, i));
    t_out.mad(i) = median (abs (t(:, i) - t_out.median(i)));
end

% Boxplots (if available)
h_fig = stk_figure ('stk_benchmark_predict');
try
    boxplot (log10 (t * 1000));
    set(gca (), 'xticklabel', t_out.rownames);
    stk_labels ('n_{obs} / n_{pred}', 'log10 (t) [ms]'); 
catch
    close (h_fig);
end

end % function


function M_prior = test_A_init ()

% M_prior = stk_model ('stk_materncov32_iso');
% M_prior.param = [0; 0];

% This works even in very releases of STK
M_prior = stk_model ();
M_prior.covariance_type = 'stk_materncov32_iso';
M_prior.param = [0; 0];

end % function


function z_prd = test_A (M_prior, n_obs, n_prd)

x_obs = (linspace (0, 1, n_obs))';
z_obs = sin (x_obs);
x_prd = rand (n_prd, 1);
z_prd = stk_predict (M_prior, x_obs, z_obs, x_prd);

end
