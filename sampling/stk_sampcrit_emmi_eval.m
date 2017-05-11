% STK_SAMPCRIT_EMMI_EVAL computes the expected maximin improvement criterion
%
% CALL: EMMI_VAL = stk_sampcrit_emmi_eval (ZP_MEAN, ZP_STD, ZI)
%
%   computes the expected maximin improvement using Monte Carlo simulation.
%   A normal distribution with mean ZP_MEAN and standard deviation ZP_STD is
%   assumed. ZI is a matrix of pareto optimal solutions.
%   The input arguments should have the following sizes
%
%       * ZP_MEAN must have size n x p
%       * ZP_STD  must have size n x p
%       * ZI      must have size np x p
%
% CALL: EMMI_VAL = stk_sampcrit_emmi_eval (ZP_MEAN, ZP_STD, ZI, NSIMU)
%
%   allows to change the number of simulations NSIMU used in the calculation of
%   the criterion.
%
% NOTE:
%
%    minimization wrt to all objectives is assumed (for now)
%
% NOTE:
%
%    *_eval function should be provided for all pointwise sampling
%       (makes them easy to use when means and std are already computed)
%
% NOTE:
%
%    Objective functions should be normalized for better performances.
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
