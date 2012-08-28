% test_quant_SUR
clear all
close all
addpath('../SMTK');

%%
M  = 3000;     % nb max de points pour l'estimation par Monte Carlo
NR = M;      
NSIM = 200;    % nb de simulations conditionnelles
Q = 6;         % nb de niveaux pour le calcul de l'esperance conditionnelle
ITER = 15;     % nb max de points pour le meta-estimateur
ML = 30;       % nb de niveaux de variation de M

COVNAME = 'materncov_iso';
SIGMA2 = 1;
NU = 1.3;
RHO = 0.3;
NOISEVARIANCE = (1e-6)^2;
ORDRE = -1;

%ESTIMATOR = quantile();
%ESTIM_PARAM = @(x)(0.99);

ESTIM_PARAM = @(x)(quantile(x, 0.92)+1e-3);
ESTIMATOR = pfail_estim();

%% ------------ Definition d'une covariance ------------
cov.name        = COVNAME;
cov.ordre       = ORDRE;

param0 = [log(SIGMA2), log(NU), log(1/RHO)]';
cov.param   = param0;

%% ------------ generation d'un M-echantillon ------------

%-------------------------%
xr.a = unifrnd(-1,1,M,1); % choix d'une distribution des 
                          % entrees et generation d'un echantillon
xr.a = sort(xr.a);        % ordonne, mieux pour les graphiques...
options.noisevariance = NOISEVARIANCE;
yr.a = simul(xr, param0, options);  % generation d'une trajectoire de processus gaussien
%-------------------------%
% xr.a=sort(normrnd(0,1,NT,1)); % autre distribution
% yr.a=fonction_y(xr.a);        % autre fonction
%-------------------------%

%% ------------ initialisation algorithme ------------
estimator = ESTIMATOR;
T = ESTIM_PARAM(yr.a);
estimator.set_param(T);

krig_param.cov  = cov;
krig_param.nsim = NSIM;
krig_param.noisevariance = NOISEVARIANCE;
krig = krig_obj(xr, krig_param);

algo_param.q    = Q;

tic
nmax = zeros(ML,1);
m = round (logspace(log10(20), log10(M), ML));
me_ifb_n = zeros(ML,4);
for k = 1:ML % boucle sur m
    nt = m(k);
    xt_ind = randperm(M);
    xt_ind = sort(xt_ind(1:nt));
    krig.set_xt(xt_ind);

    xt.a = xr.a(xt_ind,:);
    yt.a = yr.a(xt_ind,:);

    xi_ind = [1 xt_ind(nt)]; % observations initiales
    yi.a = yr.a(xi_ind) + sqrt(NOISEVARIANCE)*randn(2,1);

    % estimation par MC sur nt points
    estimator.set_data(yt.a);
    estim_star = estimator.val;
    
    % choix sequentiel des points pour construire le me

    me_val   = zeros(ITER,1);
    me_inter = zeros(ITER,2);
    me_iv = zeros(ITER,4);
   
    for i = 1:ITER
        [ind_next, SamplingCriterion, yp, me0] = me_sur (...
            xi_ind, yi, algo_param, estimator, krig);
    
        me_val(i) = me0.m;
        me_ib(i,:) = me0.ib;
        me_ifb(i,:) = me0.ifb;
    
        msg = sprintf('round %d/%d,; %d, t=%.0fs, MC=%f, meta-est=%f\r', ...
            k, ML, i, toc, estim_star, me_val(i));
        disp(msg);
    
        DEBUG = 1;
        if DEBUG == 1
        figure(1);
        	subplot(2,1,1)
        	plot(xt.a, SamplingCriterion)
        	title ('critere echantillonnage')
        	subplot(2,1,2)
% quantile
%           plot(xt.a, yt.a, xt.a, yp.a, xr.a(xi_ind), yiend.a,'ro', ...
%             		xt.a, yp.a + 2*sqrt(yp.v), 'g', xt.a, yp.a - 2*sqrt(yp.v), 'g', ...
%             		[-1 1], [me_val(i), me_val(i)], 'r');
% pfail
            plot(xt.a, yt.a, xt.a, yp.a, xr.a(xi_ind), yi.a,'ro', ...
            		xt.a, yp.a + 2*sqrt(yp.v), 'g', xt.a, yp.a - 2*sqrt(yp.v), 'g', ...
            		[-1 1], [T, T], 'r');
        	drawnow
        	title('prediction, etc')
        end
    
        xi_ind = [xi_ind xt_ind(ind_next)];
        yi.a = [yi.a; yt.a(ind_next)+sqrt(NOISEVARIANCE)*randn(1,1)];
    end
    me_ifb_n(k,:) = me_ifb(i,:);
end
figure(2)
NINIT = 2;
errorbar((NINIT+1):(NINIT+ITER), me_val, me_val - me_ib(:,1), me_ib(:,2) - me_val, 'xr');

