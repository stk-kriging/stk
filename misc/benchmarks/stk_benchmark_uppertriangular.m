% STK_BENCHMARK_UPPERTRIANGULAR times some computations with UT matrices

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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


%% Prepare benchmark

n = 100;  NREP = 200;

model = stk_model (@stk_materncov32_iso);
model.param = [0 0];
x = (linspace (0, 1, n))';
K = stk_make_matcov (model, x);

% Assume that the Cholesky factorization of K is available
C = chol (K);


%% First test: K ^ (-1)

tic ();
for i = 1:NREP
    M1 = inv (K);
end
t1 = toc ();

tic
for i = 1:NREP
    B2 = inv (C');
    M2 = B2' * B2;
end
t2 = toc ();

tic
for i = 1:NREP
    B3 = linsolve (C, eye (n), struct ('UT', true, 'TRANSA', true));
    M3 = B3' * B3;
end
t3 = toc ();

t = [t1 t2 t3]'


%% Second test: W * K^(-1) * W'

W = randn (n);

tic ();
for i = 1:NREP
    M1 = W * inv (K) * (W');
end
t1 = toc ();

tic
for i = 1:NREP
    B2 = (C') \ (W');
    M2 = B2' * B2;
end
t2 = toc ();

tic
for i = 1:NREP
    B3 = linsolve (C, W', struct ('UT', true, 'TRANSA', true));
    M3 = B3' * B3;
end
t3 = toc ();

t = [t1 t2 t3]'
