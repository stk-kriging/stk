% stk_cov_fct()                      % error incorrect nb args
% stk_cov_fct('toto')                % error toto doesn't exist
% stk_cov_fct('stk_materncov_iso')   % error cannot initialze params (defaultparam not created)

k1 = stk_cov_fct('stk_materncov_iso');
k2 = stk_cov_fct('stk_materncov32_aniso', 'dim', 1);
k3 = stk_cov_fct('stk_materncov32_aniso', 'dim', 3);

whos

assert(k1.nb_param == 3);
assert(k2.nb_param == 2);
assert(k3.nb_param == 4);

assert(k1.nb_param == get(k1, 'nb_param'));
assert(k2.nb_param == get(k2, 'nb_param'));
assert(k3.nb_param == get(k3, 'nb_param'));

t1 = k1.param
t2 = k2.param
t3 = k3.param

assert(isequal(t1, get(k1, 'param')))
assert(isequal(t2, get(k2, 'param')))
assert(isequal(t3, get(k3, 'param')))

x1 = 0.0;
x2 = zeros(1, 3);

assert(k1(x1, x1) == 1.0);
assert(k2(x1, x1) == 1.0)
assert(k3(x2, x2) == 1.0);

x1 = struct('a', 0.0);
x2 = struct('a', zeros(1, 3));

assert(k1(x1, x1) == 1.0);
assert(k2(x1, x1) == 1.0);
assert(k3(x2, x2) == 1.0);

t1 = [0; 0.5; 1.1];
t2 = [0.1; 0.4; 1.2];

k1.param = t1;                assert(isequal(k1.param, t1));  % NICER !
k1 = set(k1, 'param', t2);    assert(isequal(k1.param, t2));
k1 = stk_set_param(k1, t1);   assert(isequal(k1.param, t1));

n = 100; z = randn(n, 1);

[lb1, ub1] = stk_get_default_bounds(k1);          % use internal param (= t1)
[lb2, ub2] = stk_get_default_bounds(k1, t1);      % should be the same
[lb3, ub3] = stk_get_default_bounds(k1, t2);      % should be different
[lb4, ub4] = stk_get_default_bounds(k1, t1, z);   % using the empirical var of z

assert(isequal(lb1, lb2) && isequal(ub1, ub2));
assert(~isequal(lb1, lb3) && ~isequal(ub1, ub3));

assert(isequal(k1.param, k1.cparam));

assert(k1.sigma2 == exp(t1(1)));
assert(k1.nu     == exp(t1(2)));
assert(k1.rho    == exp(-t1(3)));
assert(k1.alpha  == exp(t1(3)));
