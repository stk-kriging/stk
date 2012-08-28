function [ind_next, SamplingCriterion, yp, me0] = ...
    me_sur (xi_ind, yi, algo_param, estimator, krig)
%
%
%
%% ------------ initialisations des objets persitants ------------
persistent Q zQ
%%%
if isempty(zQ)
    ALPHA = 0.01;
    Q  = algo_param.q;
    zQ = linspace(ALPHA/2, 1-ALPHA/2,Q);
    zQ = norminv(zQ, 0, 1);
end

%% ------------ loi a posteriori du meta-estimateur ------------

krig.set_xi(xi_ind);
krig.yi = yi;

me0 = me(estimator, krig);

DEBUG = 1;
if DEBUG
    figure(11);
       m0 = me0.m;
       cdfplot(me0.sample);
       hold on
       plot([m0 m0], ylim,'r');
       hold off
       drawnow
end

%% ------------ Stepwise Uncertainty Reduction : boucle sur les points test

krig.pred();
krig.variance();
yp = krig.yp;

SamplingCriterion = zeros(krig.nt,1);

xi_ind = [krig.xi_ind 0];
ni = length(xi_ind);

for test_ind = 1:krig.nt

    xi_ind(ni) = krig.xt_ind(test_ind);
    krig.set_xi(xi_ind);

    upsilon = zeros(Q,1);
    for k = 1:Q
        % l'observation fictive
        krig.yi.a(ni,:) =  yp.a(test_ind) + ...
            sqrt(abs(yp.v(test_ind))) * zQ(k);
       
        me_cond = me(estimator, krig);
        DEBUG = 0;
        if DEBUG
            krig.pred();
            figure(11);
               subplot (2,1,1)
                  plot(krig.xt.a, krig.ysimc(:,1:6), 'b', ...
                     krig.xi.a, krig.yi.a,'ro', ...
                     krig.xt.a, yp.a, 'r', ...
                     krig.xt.a, krig.yp.a, 'm', ...
                     krig.xt.a, yp.a + 2*sqrt(abs(yp.v)), 'g', ...
                     krig.xt.a, yp.a - 2*sqrt(abs(yp.v)), 'g')
               subplot (2,1,2)
                  cdfplot(me_cond.sample);
                  hold on
                  m_cond = me_cond.m;
                  plot([m0 m_cond], ylim,'r');
                  hold off
                  drawnow
                  keyboard
        end
        %%%
        METHOD = 2;
        switch METHOD
            case 1
                upsilon(k) = me_cond.v;
            case 2
                upsilon(k) = me_cond.m;
            case 3
                % entropie
        end
    end
    
    switch METHOD        
        case {1,3}
            % calcul de la moyenne par trapezes
            zztmp = 1/(Q-1) * ...
                (1/2*upsilon(1) + sum(upsilon(2:Q-1))  + 1/2*upsilon(Q));
            SamplingCriterion(test_ind) = zztmp;
%             if me.var * 1.05 < zztmp 
%             figure(3)
%                plot(1:Q,H, 'b'); hold on
%                plot(xlim, [me.var me.var], 'r', xlim, [zztmp zztmp], 'g')
%                hold off
%                keyboard
%             end
        case 2
            SamplingCriterion(test_ind) = me0.v - var(upsilon);
    end
end
    switch METHOD
        case {1,2,3}
            [~, ind_next] = min(SamplingCriterion);
    end
