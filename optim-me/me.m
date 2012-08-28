classdef me
    properties
        estimator
        krig
        sample
        m
        v
        ib
        ifb
    end
    methods
        function obj = me(estimator, krig)
            krig.cond();
            estimator.set_data(krig.ysimc);
            
            obj.estimator = estimator;
            obj.krig = krig;
            
            obj.sample = estimator.val;
        end
        function m = get.m(obj)
            m = mean(obj.sample);
        end
        function v = get.v(obj)
            v = var(obj.sample);
        end
        function ib = get.ib(obj)
            ib = [quantile(obj.sample', 0.025), quantile(obj.sample', 0.975)];
        end
        function ifb = get.ifb(obj)
            ci = obj.estimator.ci;
            ifb = [quantile(ci(1,:)', 0.025), quantile(ci(1,:)', 0.975), ...
                quantile(ci(2,:)', 0.025), quantile(ci(2,:)', 0.975)];   
        end
    end

end