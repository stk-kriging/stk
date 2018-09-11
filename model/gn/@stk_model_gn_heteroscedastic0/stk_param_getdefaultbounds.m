% STK_PARAM_GETDEFAULTBOUNDS [overload STK]
%
% EXPERIMENTAL CLASS WARNING:  The stk_model_gn_heteroscedastic0 class is
%    currently considered experimental.  STK users who wish to experiment with
%    it are welcome to do so, but should be aware that API-breaking changes
%    are likely to happen in future releases.  We invite them to direct any
%    questions, remarks or comments about this experimental class to the STK
%    mailing list.

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function [lb, ub] = stk_param_getdefaultbounds (gn0, xi, zi)

v = feval (gn0.variance_function, xi);

b = (v > 0);
if ~ any (b)
    stk_error (['The variance function is zero at all ' ...
        'observed locations'], 'VarianceFunctionNowherePositive');
end

% Keep only the noisy observations
u = zi(b);

TOL = 0.5;

% Bounds for log-dispersion parameter
tmp = mean ((u - mean (u)) .^ 2 ./ v(b));
lb = log (tmp) - 50;  % exp(50) is an arbitrary large number
ub = log (tmp) + TOL;

% Make sure that the initial value(s) falls within the bounds
if ~ isnan (gn0.log_dispersion)
    lb = min (lb, gn0.log_dispersion - TOL);
    ub = max (ub, gn0.log_dispersion + TOL);
end

end % function
