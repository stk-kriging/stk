mu = [1 2];     % means
sigma = [3 4];  % standard deviations
rho = 0.37;     % correlation coefficients

n = 10000;
z = 10 * (rand (n, 2) - 0.5);

% Covariance matrix (for use with mvncdf)
K11 = sigma(1) ^ 2;
K12 = sigma(1) * sigma(2) * rho;
K22 = sigma(2) ^2;

% Compute with mvncdf
tic;
p_mvncdf = mvncdf (z, mu, [K11 K12; K12 K22]);
t_mvncdf = toc;

% Compute with stk_distrib_bivnorm_cdf
tic;
p_stk = stk_distrib_bivnorm_cdf (z, mu(1), mu(2), sigma(1), sigma(2), rho);
t_stk = toc;

err = abs (p_stk - p_mvncdf);
fprintf ('t_stk = %.1f µs/eval\n', t_stk / n * 1e6);
fprintf ('t_mvncdf = %.1f µs/eval\n', t_mvncdf / n * 1e6);
fprintf ('t_mvncdf / t_stk = %.1f\n', t_mvncdf / t_stk);
fprintf ('maximal absolute difference: %.2g\n', max (err))
fprintf ('maximal relative difference: %.2g\n', max (err  ./ p1))


%%% Example of a "large" difference (approx. 1e-8 relative error)
%
% z1 = -3.798119125813876
% z2 = -4.397490942716200
%
% p1 = stk_distrib_bivnorm_cdf ([z1 z2], 1, 2, 3, 4, 0.37)
% % -> 1.0015256831575151e-02
%
% p2 = mvncdf ([z1 z2], [1 2], [9 4.44; 4.44 16]);
% % -> 1.0015256938405132e-02     (Matlab R2012a)
%
%%%%%%%% Which one is more accurate ???
