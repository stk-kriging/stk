classdef krig_obj < handle
    properties
        cov
        noisevariance
        sigma2
        
        xr
        
        Kx
        Px
        Pdim
        
        nsim
        ysim
        
        ni
        xi_ind
        xi
        nt
        xt_ind
        xt
        
        A
        B
        lambda_mu
        
        lambda
        yi
        yp
        
        ysimc
    end
    methods
        function obj = krig_obj(xr, krig_param)
            obj.cov = krig_param.cov;
            obj.noisevariance = krig_param.noisevariance;
            obj.sigma2 = exp(krig_param.cov.param(1));
            
            % creation matrice de covariance
            obj.xr = xr;
            [obj.Kx, obj.Px] = make_matcov(xr, obj.cov);  % KX: nr x nr, PX : nr x l
            obj.Kx = obj.Kx + obj.noisevariance*eye(length(xr.a));
            obj.Pdim = size(obj.Px,2);
            
            % simulations
            
            obj.nsim = krig_param.nsim;
            [V, p] = chol(obj.Kx);
            obj.ysim.a = V' * randn(size(xr.a,1), obj.nsim);
            
        end
        function set_xt(obj, xt_ind)
            obj.xt_ind = xt_ind;
            obj.nt = length(obj.xt_ind);
            obj.xt.a = obj.xr.a(xt_ind,:);
        end
        function set_xi(obj, xi_ind)
            obj.xi_ind = xi_ind;
            obj.ni = length(obj.xi_ind);
            obj.xi.a = obj.xr.a(xi_ind,:);
            
            if isempty(obj.xi_ind)
                obj.lambda = [];
            else
                if obj.Pdim == 0
                    obj.A = obj.Kx(obj.xi_ind,obj.xi_ind) +  obj.noisevariance*eye(obj.ni);
                    obj.B = obj.Kx(obj.xi_ind,obj.xt_ind);
                else
                    obj.A = [ [ obj.Kx(obj.xi_ind,obj.xi_ind) +  obj.noisevariance*eye(ni),
                                obj.Px(obj.xi_ind,:) ]
                              [obj.Px(obj.xi_ind,:)', zeros(obj.Pdim,obj.Pdim)] ];
                    obj.B = [ obj.Kx(obj.xi_ind,obj.xt_ind); obj.Px(obj.xt_ind,:)' ];
                end
                
                obj.lambda_mu = obj.A\obj.B;
                obj.lambda = obj.lambda_mu(1:obj.ni,:);
            end
        end
        function variance(obj)
            if isempty(obj.xi_ind)
                obj.yp.v = krig.sigma2 * ones(obj.nt,1);
            else
                obj.yp.v = abs(obj.sigma2 - dot(obj.lambda_mu, obj.B)'); % variance de prediction
            end
        end
        function pred(obj)
            if isempty(obj.lambda)
                obj.yp.a = zeros(obj.nt,1);
            else
                obj.yp.a = obj.lambda' * obj.yi.a; % valeurs predites
            end
        end
        function cond(obj)
            obj.ysimc = obj.ysim.a(obj.xt_ind, :)  + ...
                obj.lambda'*(repmat(obj.yi.a, 1, obj.nsim) - obj.ysim.a(obj.xi_ind, :));
        end
    end
end