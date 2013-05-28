% STK_BENCHMARK_COV2

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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
N_STEP  = 50;
N_MAX   = 2000;

covnames = { ...
    'stk_materncov32_iso', ...
    'stk_materncov52_iso', ...
    'stk_materncov_iso' };

result = struct('covname', [], 't', [], 'n', []);


%% Main loop

M = stk_options_get('stk_sf_matern', 'min_size_for_parallelization');

for j = 1:3,
    
    switch j
        case 1
            stk_parallel_stop();
        case 2
            stk_parallel_start();
            stk_options_set('stk_sf_matern', 'min_size_for_parallelization', +Inf);
        case 3
            stk_options_set('stk_sf_matern', 'min_size_for_parallelization', 1);
    end
    
    for k = 1:length(covnames), % loop over covariance functions
        
        result(j, k).covname = covnames{k};
        model = stk_model(covnames{k}, DIM);
        
        REP = 500;
        n   = N_START;
        
        while n <= N_MAX
            
            n = ceil(n * 1.3);
            
            tic;
            x = stk_sampling_regulargrid(n, DIM);
            for i = 1:REP,
                K = stk_make_matcov(model, x, x);
            end
            t = toc / REP;
            
            result(j, k).n(end+1) = n;
            result(j, k).t(end+1) = t;
            
            figure(1); cla;
            loglog(result(j, k).n, result(j, k).t, 'o-'); drawnow;
            
            REP = ceil(1/t);
        end
    end
end

stk_options_set('stk_sf_matern', 'min_size_for_parallelization', M);


%% Figure

figure(1); cla;

loglog(vertcat(result(1, :).n)', vertcat(result(1, :).t)', 'x:'); hold on;
loglog(vertcat(result(2, :).n)', vertcat(result(2, :).t)', 'o-');
loglog(vertcat(result(3, :).n)', vertcat(result(3, :).t)', 'o--');

h = legend([covnames covnames covnames], 'Location', 'NorthWest');
set(h, 'Interpreter', 'none');

xlabel('n', 'FontWeight', 'b');
ylabel('computation time', 'FontWeight', 'b');
