% STK_SAMPCRIT_EMMI_EVAL computes the EMMI criterion
%
% CALL: EMMI = stk_sampcrit_emmi_eval (ZP_MEAN, ZP_STD, ZI)
%
%    computes the value EMMI of the Expected MaxiMin Improvement (EMMI) for a
%    multi-objective minimization problem, with respect to the observed values
%    ZI, assuming Gaussian predictive distributions with means ZP_MEAN and
%    standard deviations ZP_STD.  The value of the criterion is computed
%    approximately, using Monte Carlo simulations.  The input arguments must
%    have the following sizes:
%
%       * ZP_MEAN    M x P,
%       * ZP_STD     M x P,
%       * ZI         N x P,
%
%    where M is the number of points where the EMMI must be computed, P the
%    number of objective functions to be minimized, and N the current number of
%    Pareto optimal solutions.  The output has size M x 1.
%
% CALL: EMMI = stk_sampcrit_emmi_eval (ZP_MEAN, ZP_STD, ZI, NSIMU)
%
%    allows to change the number of simulations NSIMU used in the calculation of
%    the criterion.
%
% NOTE
%
% 1) The result depends only on the non-dominated rows of ZI.
%
% 2) Multi-objective maximization problems, or mixed minimization/maximization
%    problems, can be handled by changing the sign of the corresponding
%    components of ZP_MEAN and ZI.
%
% 3) Objective functions should be normalized for better performances.
%
% REFERENCES
%
%   [1] Svenson J.D. and Santner T.J. Multiobjective optimization of
%       expensive black-box functions via expected maximin improvement.
%       Technical report, Tech. rep., 43210, Ohio University, Columbus,
%       Ohio, 2010
%
% See also: stk_sampcrit_ehvi_eval

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2016 IRT SystemX
%
%    Author:  Paul Feliot  <paul.feliot@irt-systemx.fr>

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

function EMMI = stk_sampcrit_emmi_eval (zp_mean, zp_std, zi, nsimu)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Handle empty zp
if isempty (zp_mean) || isempty (zp_std)
    EMMI = [];
    return
end

% Handle empty zi
if isempty (zi)
    stk_error ('Empty zi.', 'EmptyZi')
else
    zi = double (zi);
    % Keep only non-dominated points, and remove duplicates
    zi = unique (zi(stk_paretofind (zi), :), 'rows');
end

% Size parameters
n = size (zp_mean, 1);
[np, p] = size(zi);

% Number of simulation not provided: Defaults to nsimu = 200 x p
if nargin == 3
    nsimu = 200 * p;
end

% The criterion is calculated using Monte Carlo simulation
EMMI = zeros (n, 1);
for i = 1:n
    
    % Simulate normal distribution
    simu = bsxfun (@plus, zp_mean(i,1:p), ...
        bsxfun (@times, zp_std(i,1:p), randn (nsimu, p)));
    
    % Compute maximin improvement
    maximin = min (bsxfun(@minus, simu, zi(1,:)), [], 2);
    for k = 2:np
        maximin = max (maximin, min (bsxfun(@minus, simu, zi(k,:)), [], 2));
    end
    isdom = stk_isdominated (simu, zi);
    improvement = - maximin .* ~isdom;
    
    % Approximate expectation
    EMMI(i) = 1/nsimu * sum (improvement);
end

end % function
