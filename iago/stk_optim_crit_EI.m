% STK_OPTIM_CRIT_EI expected improvement criterion
%
% CALL: stk_optim_crit_ei()
%
% STK_OPTIM_CRIT_EI chooses evaluation point using the expected
% improvement criterion

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function [xinew, zp, samplingcrit] = stk_optim_crit_EI (algo, xg, xi_ind, zi)

xi = xg(xi_ind, :);

%% INITIAL PREDICTION
model_xg = stk_model('stk_discretecov', algo.model, xg);
zp = stk_predict(model_xg, xi_ind, zi, []);

%% ACTIVATE DISPLAY?
if algo.disp; view_init(algo, xi, zi, xg); end

%% COMPUTE THE SAMPLING CRITERION

% Compute the Expected Improvement (EI) criterion
% (the fourth argument indicates that we want to MAXIMIZE f)
Mn = max(zi);
EI = stk_distrib_normal_ei (Mn, zp.mean, sqrt(zp.var), true);
samplingcrit = - (Mn + EI);

%% PICK THE NEXT EVALUATION POINT 
[~, ind_min_samplingcrit] = min(samplingcrit);
xinew = xg(ind_min_samplingcrit, :);

%% DISPLAY SAMPLING CRITERION?
if algo.disp, view_samplingcrit(algo, xg, xi, xinew, samplingcrit, 2, false); end

end %%END stk_optim_crit_EI