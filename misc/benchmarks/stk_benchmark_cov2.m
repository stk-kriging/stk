% STK_BENCHMARK_COV2

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

%% Benchmark parameters

DIM  = 1;

N_START = 50;
N_MAX   = 2000;

covnames = { ...
    'stk_materncov32_iso', ...
    'stk_materncov52_iso', ...
    'stk_materncov_iso' };

nb_cov = length (covnames);

result = struct ('covname', [], 't', [], 'n', []);

stk_figure ('stk_benchmark_cov2');


%% Main loop

for j = 1:4,
    
    switch j
        case 1
            disp ('Using stk_parallel_engine_none...');
            stk_parallel_stop ();
        case 2
            disp ('parallelization on (if available) / msfb = Inf');
            stk_parallel_start ();
            M = stk_options_get ('stk_rbf_matern', 'min_size_for_parallelization');
            stk_options_set ('stk_rbf_matern', 'min_size_for_parallelization', +Inf);
        case 3
            disp ('parallelization on (if available) / msfb = 1');
            stk_options_set ('stk_rbf_matern', 'min_size_for_parallelization', 1);
        case 4
            fprintf ('parallelization on (if available) / msfb = %d (default)', M);
            stk_options_set ('stk_rbf_matern', 'min_size_for_parallelization', M);
    end
    
    for k = 1:nb_cov,  % loop over covariance functions
        
        result(j, k).covname = covnames{k};
        model = stk_model (covnames{k}, DIM);
        model.param = zeros (size (model.param));
        
        REP = 5000;
        n = N_START;
        
        while n <= N_MAX
            
            tic;
            x = stk_sampling_regulargrid (n, DIM);
            for i = 1:REP,
                K = stk_make_matcov (model, x, x);
            end
            t = toc / REP;
            
            result(j, k).n(end+1) = n;
            result(j, k).t(end+1) = t;
            
            cla;  loglog (result(j, k).n, result(j, k).t, 'o-');  drawnow;
            
            n = ceil (n * 1.4);
            REP = ceil (1 / t);
        end
    end
end


%% Figure

legtxt = {};  %#ok<*AGROW>

loglog (vertcat(result(1, :).n)', vertcat(result(1, :).t)', 'x:'); hold on;
for k = 1:nb_cov
    legtxt = [legtxt {sprintf('%s (par. off)', covnames{k})}];
end

loglog (vertcat(result(2, :).n)', vertcat(result(2, :).t)', 'o-');
for k = 1:nb_cov
    legtxt = [legtxt {sprintf('%s (par. on, msfp=+Inf)', covnames{k})}];
end

loglog (vertcat(result(3, :).n)', vertcat(result(3, :).t)', 's--');
for k = 1:nb_cov
    legtxt = [legtxt {sprintf('%s (par. on, msfp=1)', covnames{k})}];
end

loglog (vertcat(result(4, :).n)', vertcat(result(4, :).t)', 'd-.');
for k = 1:nb_cov
    legtxt = [legtxt {sprintf('%s (par. on, msfp=%d)', covnames{k}, M)}];
end

h = legend (legtxt, 'Location', 'NorthWest');
set (h, 'Interpreter', 'none');

stk_labels ('n', 'computation time');
