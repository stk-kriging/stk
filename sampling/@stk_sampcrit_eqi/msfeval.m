% MSFEVAL ...  FIXME: Missing documentation

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec & EDF R&D
%
%    Authors:  Tom Assouline  <tom.assouline@supelec.fr>
%              Julien Bect    <julien.bect@centralesupelec.fr>

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

function crit_val = msfeval (crit, mean, std)

threshold = get_threshold_value (crit);
bminimize = get_bminimize (crit);
quantile_order = get_threshold_quantile_order (crit);
model = get_model (crit);

Ne = 30; %number of observation
N_EQI = 10^5;  % Test

% eval_budget = get_eval_budget(crit);

% Definition of the variance of the noise
noise_var = exp (get_lognoisevariance (model));
% if noise_var is real (homoscedastic variance)
if stk_length(noise_var)==1
    
    noise_var = noise_var ./ (N_EQI - Ne);
    
else   % case heteroscedastic variance
    noise_var = zeros(stk_length(std),1);
end

tmp = (std .^ 2) ./ (noise_var + std .^ 2);
quantile_moy = mean + (norminv (quantile_order)) * (sqrt (noise_var .* tmp));
quantile_var = (std .^ 2) .* tmp;

crit_val = stk_distrib_normal_ei (threshold, ...
    quantile_moy, sqrt(quantile_var), bminimize);

end
