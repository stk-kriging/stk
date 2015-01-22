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

function [xi, zi, algo] = stk_optim_addevals (algo, xi, zi, xinew)

assert (size (xi, 1) == size (zi, 1));

% DESIGN CHOICE: the noise variance associated with the observations is stored
%   in algo.model.lognoisevariance, as everywhere else in STK. Therefore, we
%   should *not* use stk_ndf objects for xi and xinew
assert (~ isa (xi, 'stk_ndf'));  assert (~ isa (xinew, 'stk_ndf'));

% Evaluate
zinew = stk_feval (algo.f, xinew);

% NOTE: In some situations, stk_feval (f, ...) returns multivariate results,
%   under the form of an stk_dataframe with more than one column. For instance,
%   a batch Monte Carlo simulator typically returns the empirical mean and 
%   variance of a batch of evaluations. That's ok.

if isempty (xi)
    xi = xinew;
    zi = zinew;
else
    xi = [xi; xinew];
    zi = [zi; zinew];
end

% HETEROSCEDATIC case: Fetch the value of the variance of the noise from
%    algo.xg0 and update algo.model.lognoisevariance with it.
if isa (algo.xg0, 'stk_ndf')
    [b, pos] = ismember (xinew, algo.xg0, 'rows');  assert (all (b));
    lnv_new = log (algo.xg0.noisevariance(pos));
    algo.model.lognoisevariance = [algo.model.lognoisevariance; lnv_new];    
end

% === SAFETY NETS ===
assert (size (zi, 1) == size (xi, 1));
assert (noise_params_consistency (algo, xi));

end % function stk_optim_addevals
