%#ok<*TRYNC>
%#ok<*CTCH>
%#ok<*NASGU>
%#ok<*LERR>
%#ok<*NOPTS>


%% Check inheritance / default constructor

k = stk_cov();
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert(~isa(k, 'stk_hetnoisecov'));
assert(~isa(k, 'stk_homnoisecov'));
assert(~isa(k, 'stk_nullcov'));

k = stk_generalcov();
assert( isa(k, 'stk_cov')); %%%
assert( isa(k, 'stk_generalcov')); %%%
assert(~isa(k, 'stk_hetnoisecov'));
assert(~isa(k, 'stk_homnoisecov'));
assert(~isa(k, 'stk_nullcov'));

k = stk_hetnoisecov();
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert( isa(k, 'stk_hetnoisecov')); %%%
assert(~isa(k, 'stk_homnoisecov'));
assert(~isa(k, 'stk_nullcov'));

k = stk_homnoisecov();
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert( isa(k, 'stk_hetnoisecov')); %%%
assert( isa(k, 'stk_homnoisecov')); %%%
assert(~isa(k, 'stk_nullcov'));

k = stk_nullcov();
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert( isa(k, 'stk_hetnoisecov')); %%%
assert( isa(k, 'stk_homnoisecov')); %%%
assert( isa(k, 'stk_nullcov')); %%%


%% Check inheritance / stk_cov constructor

k = stk_cov('NULL');
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert(~isa(k, 'stk_hetnoisecov'));
assert(~isa(k, 'stk_homnoisecov'));
assert(~isa(k, 'stk_nullcov'));

k = stk_cov('stk_hetnoisecov');
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert( isa(k, 'stk_hetnoisecov')); %%%
assert(~isa(k, 'stk_homnoisecov'));
assert(~isa(k, 'stk_nullcov'));

k = stk_cov('stk_homnoisecov');
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert( isa(k, 'stk_hetnoisecov')); %%%
assert( isa(k, 'stk_homnoisecov')); %%%
assert(~isa(k, 'stk_nullcov'));

k = stk_cov('stk_nullcov');
assert( isa(k, 'stk_cov')); %%%
assert(~isa(k, 'stk_generalcov'));
assert( isa(k, 'stk_hetnoisecov')); %%%
assert( isa(k, 'stk_homnoisecov')); %%%
assert( isa(k, 'stk_nullcov')); %%%

k = stk_cov('stk_materncov32_aniso');
assert( isa(k, 'stk_cov')); %%%
assert( isa(k, 'stk_generalcov')); %%%
assert(~isa(k, 'stk_hetnoisecov'));
assert(~isa(k, 'stk_homnoisecov'));
assert(~isa(k, 'stk_nullcov'));


%% k(0, 0) / default constructor

k = stk_cov();
try
    t = k(0, 0); 
catch 
    e = lasterror(); 
    assert(strcmp(e.identifier, 'STK:feval:MethodUndefined'));
end

k = stk_generalcov();
t = k(0, 0); assert(t == 1.0);

k = stk_hetnoisecov();
t = k(0, 0); assert(t == 1.0);

k = stk_homnoisecov();
t = k(0, 0); assert(t == 1.0);

k = stk_nullcov();
t = k(0, 0); assert(t == 0.0);


%% k(0, 0) / stk_cov constructor

k = stk_cov('NULL');
try
    t = k(0, 0); %#ok<NASGU>
catch 
    e = lasterror(); 
    assert(strcmp(e.identifier, 'STK:feval:MethodUndefined'));
end

k = stk_cov('stk_hetnoisecov');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_homnoisecov');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_nullcov');
t = k(0, 0); assert(t == 0.0);

k = stk_cov('stk_materncov32_iso');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_materncov32_aniso');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_materncov52_iso');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_materncov52_aniso');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_materncov_iso');
t = k(0, 0); assert(t == 1.0);

k = stk_cov('stk_materncov_aniso');
t = k(0, 0); assert(t == 1.0);


%% set/get cparam

k = stk_cov('NULL');
try
    p = k.cparam;
catch 
    e = lasterror(); 
    assert(strcmp(e.identifier, 'STK:stk_get_cparam:MethodUndefined'));
end

k = stk_cov('stk_hetnoisecov');
assert(isempty(k.cparam));
k.cparam = [];  % valid call to set_cparam
try
    p1 = k.cparam(1); % invalid call to stk_get_cparam
    error('What am I doing here ?');
end
try
    k.cparam = 2.3;  % invalid call to stk_set_cparam
    error('What am I doing here ?');
catch
    e = lasterror(); 
    assert(strcmp(e.identifier, 'STK:stk_set_cparam:IncorrectArgument'));   
end
    
k = stk_cov('stk_homnoisecov');
p = k.cparam; assert(length(p) == 1); % 1 param -> logvariance
assert(isequal(p, k.cparam(1)));
k.cparam = 2.78; assert(k.cparam(1) == 2.78);
k.cparam(1) = 2.54; assert(k.variance == exp(2.54));

k = stk_cov('stk_nullcov');
assert(isempty(k.cparam));
k.cparam = [];  % valid call to set_cparam
try
    p1 = k.cparam(1); % invalid call to stk_get_cparam
    error('What am I doing here ?');
end
try
    k.cparam = 2.3;  % invalid call to set_cparam
    error('What am I doing here ?');
catch 
    e = lasterror();
    assert(strcmp(e.identifier, 'STK:stk_set_cparam:IncorrectArgument'));   
end

k = stk_cov('stk_materncov32_iso');
p = k.cparam; assert(length(p) == 2); % 2 parameters: logvariance & logalpha
assert(isequal(p(:), [k.cparam(1); k.cparam(2)]));
k.cparam(1) = 0.32; k.cparam(2) = -0.68;
assert(isequal(k.cparam(:), [0.32; -0.68]));

k = stk_cov('stk_materncov_aniso');
p = k.cparam; assert(length(p) == 3); % 3 parameters: logvariance, lognu, logalpha
assert(isequal(p(:), [k.cparam(1); k.cparam(2); k.cparam(3)]));
k.cparam(1) = 0.32; k.cparam(2) = -0.68; k.param(3) = 1.77;
assert(isequal(k.cparam(:), [0.32; -0.68; 1.77]));


%% get param

k = stk_cov();
try
    k.param
    error('What am I doing here ?');
catch
    e = lasterror(); 
    assert(strcmp(e.identifier, 'STK:stk_get_param:MethodUndefined'));   
end

k = stk_cov('stk_hetnoisecov');        param = k.param
k = stk_cov('stk_homnoisecov');        param = k.param
k = stk_cov('stk_nullcov');            param = k.param
k = stk_cov('stk_materncov32_aniso');  param = k.param


%% set/get name

k = stk_cov();                         assert(strcmp(k.name, 'NULL'));
k.name = 'dudule';                     assert(strcmp(k.name, 'dudule'));

k = stk_cov('stk_hetnoisecov');        assert(strcmp(k.name, 'stk_hetnoisecov'));
k.name = 'dudule';                     assert(strcmp(k.name, 'dudule'));

k = stk_cov('stk_homnoisecov');        assert(strcmp(k.name, 'stk_homnoisecov'));
k.name = 'dudule';                     assert(strcmp(k.name, 'dudule'));

k = stk_cov('stk_nullcov');            assert(strcmp(k.name, 'stk_nullcov'));
k.name = 'dudule';                     assert(strcmp(k.name, 'dudule'));

k = stk_cov('stk_materncov32_aniso');  assert(strcmp(k.name, 'stk_materncov32_aniso'));
k.name = 'dudule';                     assert(strcmp(k.name, 'dudule'));


%% miscellaneous

% stk_cov()                      % error incorrect nb args
% stk_cov('toto')                % error toto doesn't exist
% stk_cov('stk_materncov_iso')   % error cannot initialze params (defaultparam not created)

k1 = stk_cov('stk_materncov_iso');
k2 = stk_cov('stk_materncov32_aniso', 'dim', 1);
k3 = stk_cov('stk_materncov32_aniso', 'dim', 3);

assert(length(k1.cparam) == 3);
assert(length(k2.cparam) == 2);
assert(length(k3.cparam) == 4);

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
k1 = set(k1, 'param', t1);    assert(isequal(k1.param, t1));

n = 100; z = randn(n, 1);

[lb1, ub1] = stk_get_defaultbounds(k1);          % use internal param (= t1)
[lb2, ub2] = stk_get_defaultbounds(k1, t1);      % should be the same
[lb3, ub3] = stk_get_defaultbounds(k1, t2);      % should be different
[lb4, ub4] = stk_get_defaultbounds(k1, t1, z);   % using the empirical var of z

assert(isequal(lb1, lb2) && isequal(ub1, ub2));
assert(~isequal(lb1, lb3) && ~isequal(ub1, ub3));

assert(isequal(k1.param, k1.cparam));

assert(k1.sigma2 == exp(t1(1)));
assert(k1.nu     == exp(t1(2)));
assert(k1.rho    == exp(-t1(3)));
assert(k1.alpha  == exp(t1(3)));

k1.sigma2 = 3.0; assert(stk_isequal_tolrel(k1.sigma2, 3.0));
k1.sigma2 = 2.0; assert(stk_isequal_tolrel(k1.sigma2, 2.0));
