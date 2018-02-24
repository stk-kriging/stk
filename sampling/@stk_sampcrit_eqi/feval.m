% @STK_SAMPCRIT_EQI/FEVAL [overload base function]
%
% See also: feval

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
%    Copyright (C) 2016 EDF R&D
%
%    Authors:  Tom Assouline, Florent Autret & Stefano Duhamel (for EDF R&D)
%              Julien Bect  <julien.bect@centralesupelec.fr>

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

function [EQI, zp] = feval (crit, x, tau2)

zp = stk_predict (crit.model, x);

zp_mean = zp.mean;
zp_std = sqrt (zp.var);

if nargin < 3
    % If tau2 is missing, compute tau2 assuming that a batch of size
    % crit.point_batch_size will be made at the selected evaluation point.
    % Otherwise, use the value of tau2 provided as an input argument.  Note
    % that the value of crit.point_batch_size is ignored in this second case.
    if stk_isnoisy (crit.model)
        
        if isa (crit.point_batch_size, 'function_handle')
            n = stk_length (get (crit.model, 'input_data'));
            pbs = feval (crit.point_batch_size, x, n);
        else
            pbs = crit.point_batch_size;
        end
        
        prior_model = get (crit.model, 'prior_model');
        tau2 = (exp (prior_model.lognoisevariance)) / pbs;
        
    else
        tau2 = 0;
    end
end

tmp = (zp_std .^ 2) ./ (tau2 + zp_std .^ 2);
tmp(zp_std == 0) = 0.0;
quantile_moy = zp_mean + crit.quantile_value * (sqrt (tau2 .* tmp));
quantile_var = (zp_std .^ 2) .* tmp;

EQI = stk_sampcrit_ei_eval ( ...
    quantile_moy, sqrt (quantile_var), crit.current_minimum);

end % function
