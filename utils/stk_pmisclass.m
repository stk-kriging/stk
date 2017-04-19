% STK_PMISCLASS computes the (expected) probability of misclassification
%
% CALL: P = stk_pmisclass (U, Z_PRED)
%
%    computes the probability of misclassification P with respect to the
%    threshold U using the posterior means and variances contained in Z_PRED,
%    where Z_PRED is a dataframe with column names 'mean' and 'var' (as
%    returned by stk_predict).
%
% CALL: P = stk_pmisclass (U, Z1_PRED, K12, K22)
%
%    computes the expected probability of misclassification P with respect to
%    the threshold U at a set of locations X1, assuming that observations are
%    made at another set of location X2, where:
%
%     * Z1_PRED contains, as above, the posterior means and variances at X1;
%
%     * K12 is the posterior covariance matrix between the values of the process
%       at X1 and the observations (at X2);
%
%     * K22 is the posterior covariance matrix of the observations.
%
% See also: stk_predict, stk_example_doe04

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function pmisclass = stk_pmisclass (u, z1_pred, K12, K22)

if ~ isscalar (u)
    stk_error ('u should be a scalar.', 'IncorrectSize');
end

% Kriging mean (reduced to the case u = 0)
m = bsxfun (@minus, get (z1_pred, 'mean'), u);

% Kriging variances and standard deviations
v = get (z1_pred, 'var');
s = sqrt (v);

% Compute the probability p that the response at xt is *above* 0 and q = 1 - p
[q, p] = stk_distrib_normal_cdf (0, m, s);

if nargin < 4,
    
    % Current posterior probability of misclassification
    pmisclass = min (p, q);
    
else
    
    % Variance of the future predictor
    if isscalar (K22)
        if K22 < 0
            stk_error ('K22 should be positive.', 'InvalidArgument');
        elseif K22 == 0
            fpv = v;
        else
            fpv = (K12 .^ 2) / K22;
        end
    else
        R = stk_cholcov (K22);
        M = K12 / R;
        fpv = sum (M .^ 2, 2);        
    end
    
    % Standard deviation of the future predictor
    fps = sqrt (min (fpv, v));
       
    % Proba that the future predictor is below u
    p1 = stk_distrib_normal_cdf (0, m, fps);
      
    % Proba that both the response and the future predictor are below u
    p2 = stk_distrib_bivnorm_cdf ([0 0], m, m, fps, s, fps ./ s);

    pmisclass = q + p1 - 2 * p2;
end

end % function
