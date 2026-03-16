% STK_EEM_EXCURSION computes the Expected Estimator Modification (EEM)
% criterion for excursion set estimation problems of the form f(x) >= T.
%
% CALL: M = stk_eem_excursion (U, MU, COV, CROSSCOV)
%
%    computes the expected estimator modification M with respect to the
%    threshold U using the posterior mean MU, the covariance of the candidate
%    points COV and the cross covariance CROSSCOV of the
%    candidate points and a set of test points.

% See also: stk_predict, stk_make_crosscovcond

% Copyright Notice
%
%    Copyright (C) 2025 CentraleSupelec
%
%    Author:  Romain Ait Abdelmalek-Lomenech  <romain.ait@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function M = stk_eem_excursion (u, mu, cov, crosscov)

if ~ isscalar (u)
    stk_error ('u should be a scalar.', 'IncorrectSize');
end

if nargin < 4
    stk_error('Not enough arguments', 'IncorrectSize')
end

% Kriging mean (reduced to the case u = 0)
mu = mu - u;

% Variance
var = sqrt(sum((crosscov/cov).*crosscov, 2));

% Compute the probability p that the response at xt is below U and q = 1 - p
[p, q] = stk_distrib_normal_cdf (0, mu, var);

% Ponctual probability of change
indicator = (mu > 0);
M = indicator.*p + (1-indicator).*q;

% EEM
M = mean(M);

end % function
