%% Build from plain numerical data

n = 10;
x = rand (n, 3);
z = rand (n, 1);

xz0 = stk_iodata ()
xz1 = stk_iodata (x, [])
xz2 = stk_iodata ([], z)
xz3 = stk_iodata (x, z)
xz3b = stk_iodata (x, z, 'rep_mode', 'ignore')
xz3c = stk_iodata (x, z, 'rep_mode', 'forbid')
xz3d = stk_iodata (x, z, 'rep_mode', 'gather')


%% forbid

xz4 = stk_iodata ([x; x], [z; z])                       % OK (default: ignore)
xz5 = stk_iodata ([x; x], [z; z], 'rep_mode', 'ignore') % OK (the same)
xz6 = stk_iodata ([x; x], [z; z], 'rep_mode', 'gather') % OK
% xz5 = stk_iodata ([x; x], [z; z], 'rep_mode', 'forbid') % ERROR


%% Build from replication data

n = 10;  nrep_max = 5;
x = rand (n, 3);
z_mean = randn (n, 1);
z_var  = rand (n, 1);
z_rep  = randi (nrep_max, n, 1);
xz = stk_iodata (x, z_mean, z_var, z_rep);


%% Noise: tests with an stk_gaussiannoise_het0 object

N = stk_gaussiannoise_het0 (@(x) x .^ 2, 1.0);

x = (1:5)';
K1 = stk_covmat_noise (N, x)
assert (isequal (K1, diag ([1 4 9 16 25])))

data = stk_iodata (x, []);
K2 = stk_covmat_noise (N, data)
assert (isequal (K2, diag ([1 4 9 16 25])))

data = stk_iodata ([x; x], []);
K3 = stk_covmat_noise (N, data)
assert (isequal (K3, diag ([1 4 9 16 25 1 4 9 16 25])))

data = stk_iodata ([x; x], [], 'rep_mode', 'gather');
K4 = stk_covmat_noise (N, data)
assert (isequal (K4, diag ([1 4 9 16 25] / 2)))

data = stk_iodata (x, [], [], [1; 4; 1; 8; 1]);
K5 = stk_covmat_noise (N, data)
assert (isequal (K5, diag ([1 1 9 2 25])))


%% Noise: tests with a classical homoscedastic model

dim = 3;
M = stk_model (@stk_materncov52_aniso, dim);
M.param = [0 0 0 0];
M.lognoisevariance = 0.0

n = 2;
x = rand (n, dim);

K1 = stk_make_matcov (M, x);
assert (isequal (diag (K1), [2; 2]))

K1_ = stk_covmat_noise (M, x)
assert (isequal (K1_, diag ([1; 1])))

K2 = stk_make_matcov (M, x, x);
assert (isequal (diag (K2), [1; 1]))

K3 = stk_make_matcov (M, [x; x]);
assert (isequal (diag (K3), [2; 2; 2; 2]))

K4 = stk_make_matcov (M, [x; x], [x; x]);
assert (isequal (diag (K4), [1; 1; 1; 1]))

data = stk_iodata (x, []);

K5 = stk_make_matcov (M, data);
assert (isequal (diag (K5), [2; 2]))

K5_ = stk_covmat_noise (M, data);
assert (isequal (K5_, diag ([1; 1])))

K6 = stk_make_matcov (M, data, x);
assert (isequal (diag (K6), [1; 1]))

K7 = stk_make_matcov (M, data, data);
assert (isequal (diag (K7), [1; 1]))

data = stk_iodata ([x; x; x; x], [], 'rep_mode', 'gather');
K8 = stk_make_matcov (M, data);
assert (isequal (diag (K8), [1.25; 1.25]))

K8_ = stk_covmat_noise (M, data)
assert (isequal (K8_, diag ([0.25; 0.25])))

%!test essai_stk_iodata

%#ok<*NOPTS,*NASGU>