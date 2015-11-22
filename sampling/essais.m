%%
% nargin == 0, no disp

c = stk_sampcrit_base ();
c = stk_sampcrit_singleobjoptim ();
c = stk_sampcrit_modelbased ();
c = stk_sampcrit_thresholdbasedoptim ();
c = stk_sampcrit_ei ();


%%
% nargin == 0, disp

c = stk_sampcrit_base ()
c = stk_sampcrit_singleobjoptim ()
c = stk_sampcrit_modelbased ()
c = stk_sampcrit_thresholdbasedoptim ()
c = stk_sampcrit_ei ()


%%
% Majuscules ou not Majuscules ?

% stk_sampcrit_base                 -- stk_sampcrit_base
% stk_sampcrit_singleobjoptim       -- stk_sampcrit_singleObjOptim
% stk_sampcrit_modelbased           -- stk_sampcrit_modelBased
% stk_sampcrit_thresholdbasedoptim  -- stk_sampcrit_thresholdBasedOptim
% stk_sampcrit_ei                   -- stk_sampcrit_EI
% stk_model_gpposterior             -- stk_model_GPposterior
% stk_model_update                  -- stk_model_update


%%
% Data: stk_example_doe3

f = @(x)(x .* sin (x));
BOX = stk_hrect ([0; 12], {'x'});

N0 = 3;  % Initial design
xi = stk_sampling_regulargrid (N0, 1, BOX);
zi = stk_feval (f, xi);

% GP prior
M_prior = stk_model ('stk_materncov52_iso');
SIGMA2 = 4.0 ^ 2;  % variance parameter
RHO1 = 2.0;        % scale (range) parameter
M_prior.param = log ([SIGMA2; 1/RHO1]);

xt = 5;

zp = stk_predict (M_prior, xi, zi, xt);
Jt = stk_distrib_normal_ei (max (zi), zp.mean, sqrt (zp.var), false)


%%
% evaluation du critere EI / OOP / first approach

M_post = stk_model_gpposterior (M_prior, xi, zi);
J = stk_sampcrit_ei (M_post, 'maximize');  % default: 'best evaluation' mode
Jt = J (xt)  % ou encore: Jt = feval (J, xt)


%%
% evaluation du critere EI / OOP / second approach

J = stk_sampcrit_ei (M_prior, 'maximize');  % default: 'best evaluation' mode
J = stk_model_update (J, xi, zi);
Jt = J (xt)  % ou encore: Jt = feval (J, xt)


%%
% une fonction "stk_sampcrit_ei_eval" / premiere syntaxe

zp = stk_predict (M_prior, xi, zi, xt);
Jt = stk_sampcrit_ei_eval (xt, zp, 'maximize', [], max (zi))


%%
% une fonction "stk_sampcrit_ei_eval" / deuxieme syntaxe

M_post = stk_model_gpposterior (M_prior, xi, zi);
Jt = stk_sampcrit_ei_eval (xt, M_post, 'maximize', 'best evaluation')
%Jt = stk_sampcrit_ei_eval (xt, M_post, 'maximize', 'best quantile');
%Jt = stk_sampcrit_ei_eval (xt, M_post, 'maximize', [], max (zi));


%%
% Tentative de regle generale...
%
% Pour un critere *quelconque* XXX, on aurait une methode :
%
%    Jt = stk_sampcrit_XXX_eval (xt, ...)
%
% Pour un critere *ponctuel* XXX, on peut preciser deux syntaxes possibles :
%
%    Jt = stk_sampcrit_XXX_eval (xt, M_post, ...)
%
%    Jt = stk_sampcrit_XXX_eval (xt, zp, ...)
%


%%
% TODO: check that everything works properly for M_prior a struct
