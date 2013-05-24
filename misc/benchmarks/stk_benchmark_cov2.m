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


%% Loop over covariance functions

for k = 1:length(covnames),
    
    result(k).covname = covnames{k};
    model = stk_model(covnames{k}, DIM);
    
    REP  = 5000;
    n    = N_START;
    
    while n <= N_MAX
        
        n = ceil(n * 1.1);
        
        tic;
        x = stk_sampling_regulargrid(n, DIM);
        for i = 1:REP,
            K = [];
            K = stk_make_matcov(model, x, x);
        end
        t = toc / REP;
        
        result(k).n(end+1) = n;
        result(k).t(end+1) = t;
        
        figure(1); cla; plot(result(k).n, result(k).t, 'o-'); drawnow;
        
        REP = ceil(1/t);
    end
    
    %result(k).t = result(k).t / result(k).t(end);
end


%% Final figure

figure(1); cla;

loglog(vertcat(result.n)', vertcat(result.t)', 'o-');

h = legend(covnames, 'Location', 'NorthWest');
set(h, 'Interpreter', 'none')

xlabel('n', 'FontWeight', 'b');
ylabel('computation time', 'FontWeight', 'b');
