% STK_BENCHMARK_BIVNORM

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

mu = [1 2];     % means
sigma = [3 4];  % standard deviations
rho = 0.37;     % correlation coefficients

n = 1e5;
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
fprintf ('maximal relative difference: %.2g\n', max (err  ./ p_stk))


%%% Example of a "large" difference (approx. 1e-8 relative error)
%
% z1 = -3.798119125813876
% z2 = -4.397490942716200
%
% p1 = stk_distrib_bivnorm_cdf ([z1 z2], 1, 2, 3, 4, 0.37)
% % -> 1.0015256831575151e-02
%
% p2 = mvncdf ([z1 z2], [1 2], [9 4.44; 4.44 16]);
% % -> 1.0015256938405132e-02   (Matlab R2012a)
% % -> 1.0015256831575156e-02   (Matlab R2016a)
