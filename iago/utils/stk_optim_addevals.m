% STK_OPTIM_ADDEVALS add evaluations for optimization
%
% CALL: stk_optim_addevals()
%
% STK_OPTIM_INIT sets parameters of the optimization algorithm

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Authors:  Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function [xi, zi, algo, zi_new] = stk_optim_addevals (algo, xi, zi, xi_new)

assert (size (xi, 1) == size (zi, 1));

% Evaluate
zi_new = stk_feval (algo.f, xi_new);

% NOTE: In some situations, stk_feval (f, ...) returns multivariate results,
%   under the form of an stk_dataframe with more than one column. For instance,
%   a batch Monte Carlo simulator typically returns the empirical mean and
%   variance of a batch of evaluations. That's ok.

% Concatenate with previously available evaluation results (if any)
if algo.gather_repetitions,
    % Three-column representation of evaluation results
    [xi, zi] = stk_gather_repetitions (xi, zi, xi_new, zi_new);
else
    % Simple one-column reprsentation of evaluation results
    xi = [xi; xi_new];
    zi = [zi; zi_new];
end

% HETEROSCEDATIC case: Fetch the value of the variance of the noise from
%    algo.noisevariance and update algo.model.lognoisevariance with it.
if ~ isscalar (algo.noisevariance)
    [b, pos] = ismember (xi, algo.xg0, 'rows');  assert (all (b));    
    algo.model.lognoisevariance = log (algo.noisevariance(pos));
    % CAREFUL: algo.model.lognoisevariance contains the lnv for *one*
    % evaluation => repetitions will be taken into account elsewhere
end

% === SAFETY NETS ===
assert (size (zi, 1) == size (xi, 1));

end % function
