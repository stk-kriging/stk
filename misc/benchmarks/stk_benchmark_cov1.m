% STK_BENCHMARK_COV1

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

DIM = 1;  N = 500;  REP = 5;

covname = 'stk_materncov_iso';


%% Evaluate computation time
    
model = stk_model (covname, DIM);
model.param = [0 0 0];

tic;
for i = 1:REP,
    x = stk_sampling_regulargrid (N, DIM);
    K = stk_make_matcov (model, x, x);
end
t = toc / REP;

fprintf ('% 20s: %.3f seconds\n', covname, t);
