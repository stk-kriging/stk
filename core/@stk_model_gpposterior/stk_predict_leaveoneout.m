% STK_PREDICT_LEAVEONEOUT [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2017 LNE
%
%    Authors:  Remi Stroh   <remi.stroh@lne.fr>
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

function [LOO_pred, LOO_res] = stk_predict_leaveoneout (M_post)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

prior_model = M_post.prior_model;

% Compute the covariance matrix, and the trend matrix
% (this covariance matrix K takes the noise into account)
[K, P] = stk_make_matcov (prior_model, M_post.input_data);
simple_kriging = (size (P, 2) == 0);

% If simple kriging, just compute the inverse covariance matrix
if simple_kriging
    R = inv (K);
else
    % Use a more complex formula ("virtual cross-validation")
    P_K = P' / K;
    R = K \ (eye (size (K)) - P * ((P_K * P) \ P_K));
    % I = inv (K);
    % R = I - I * P * (inv (P' * I * P)) * P' * I;
end
dR = diag (R);  % The diagonal of the LOO matrix

% Mean
zi = M_post.output_data;
raw_res = R * zi ./ dR;  % Compute "raw" residuals
zp_mean = zi - raw_res;  % LOO prediction

% Variance
noisevariance = exp (M_post.prior_model.lognoisevariance);
zp_var = max (0, 1 ./ dR - noisevariance);

LOO_pred = stk_dataframe (horzcat (zp_mean, zp_var), {'mean', 'var'});

% Compute residuals ?
if nargout ~= 1
    
    % Compute normalized residual
    % norm_res = (zi - zp_mean) ./ (sqrt (noisevariance + zp_var));
    norm_res = (sqrt (dR)) .* raw_res;
    
    % Pack results into a dataframe
    LOO_res = stk_dataframe (horzcat (raw_res, norm_res), ...
        {'residuals', 'norm_res'});
end

% Create LOO cross-validation plots?
if nargout == 0
    
    % Plot predictions VS observations (left planel)...
    stk_subplot (1, 2, 1);  stk_plot_predvsobs (M_post.output_data, LOO_pred);
    
    % ...and normalized residuals (right panel)
    stk_subplot (1, 2, 2);   stk_plot_histnormres (LOO_res.norm_res);
    
end

end % function


%!test  % Check virtual Leave-One-Out formula
%!
%! n = 20;  d = 1;
%! x_obs = stk_sampling_regulargrid (n, d, [0; 2*pi]);
%! z_obs = stk_feval (@sin, x_obs);
%! 
%! lm_list = {stk_lm_null, stk_lm_constant, stk_lm_affine};
%! 
%! for j = 0:2
%!     for k = 1:(length (lm_list))
%!         
%!         model = stk_model ('stk_materncov32_iso', d);
%!         model.lm = lm_list{k};
%!         model.param = log ([1; 5]);
%!         
%!         switch j  % test various scenarios for lognoisevariance
%!             case 0
%!                 model.lognoisevariance = -inf;
%!             case 1
%!                 model.lognoisevariance = 0;
%!             case 2
%!                 model.lognoisevariance = (1 + rand (n, 1)) * 1e-3;
%!         end
%!         
%!         M_post = stk_model_gpposterior (model, x_obs, z_obs);
%!         
%!         [loo_pred, loo_res] = stk_predict_leaveoneout (M_post);
%!         [direct_pred, direct_res] = stk_predict_leaveoneout_direct (M_post);
%!         
%!         assert (stk_isequal_tolrel (loo_pred, direct_pred));
%!         assert (stk_isequal_tolrel (loo_res, direct_res));
%!         
%!     end
%! end
