function r = sqp_quadprog_testg (x)

r = [sum(abs(x).^2)-10; ...
    x(2)*x(3)-5*x(4)*x(5); ...
    x(1)^3+x(2)^3+1 ];

end % function
