classdef pfail_estim < handle
    properties
        T
        val
        ci
    end
    properties (SetAccess = private)
        X
        N
    end
    methods
        function obj = pfail_estim(T)
            if nargin > 0
                obj.T = T;
            end
        end
        function obj = set_param (obj, T)
            obj.T = T;
        end
        function obj = set_data (obj, X)
            obj.X = X;
            obj.N = size(X,1);
        end
        function alpha = get.val(obj)
            alpha = 1/obj.N * sum(obj.X > obj.T);
        end
        function iv = get.ci(obj)
            M = obj.val;

            q = 1.96; % alpha = 0.05; norminv(1-alpha/2);
            lb = M - q*sqrt(1/obj.N * M.*(1-M));
            lu = M + q*sqrt(1/obj.N * M.*(1-M));
            iv = [lb; lu];
        end
    end
end