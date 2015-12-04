function obj = sqp_quadprog_testf (x)

obj = exp (prod (x)) - 0.5*(x(1)^3 + x(2)^3 + 1)^2;

end % function
