% STK_PREDICT_LEAVEONEOUT computes LOO predictions and residuals
%
% CALL: LOO_PRED = stk_predict_leaveoneout (M_POSTERIOR)
%
% CALL: [LOO_PRED, LOO_RES] = stk_predict_leaveoneout (M_POSTERIOR)


% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function [LOO_pred, LOO_res] = stk_predict_leaveoneout (M_post)

if nargin > 1,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Heteroscedatic noise ?
heteroscedastic = ~ isscalar (M_post.prior_model.lognoisevariance);

% Compute residuals ?
compute_LOO_res = (nargout > 1);

n = size (M_post.input_data, 1);
zp_mean = zeros (n, 1);
zp_var = zeros (n, 1);

if compute_LOO_res
    res = zeros (n, 1);
    res_norm = zeros (n, 1);
    sigma = exp (0.5 * M_post.prior_model.lognoisevariance);
end
    
for i = 1:n  % FIXME: use "virtual cross-validation" formulae
    
    xx = M_post.input_data;   xx(i, :) = [];  xt = M_post.input_data(i, :);
    zz = M_post.output_data;  zz(i, :) = [];  zt = M_post.output_data(i, :);
    
    prior_model = M_post.prior_model;
    
    % In the heteroscedastic case, the vector of log-variances for the
    % noise is stored in prior_model.lognoisevariance.  This vector must be
    % modified too, when performing cross-validation.
    if heteroscedastic
        prior_model.lognoisevariance(i) = [];
    end
    
    zp = stk_predict (prior_model, xx, zz, xt);  
    
    zp_mean(i) = zp.mean;
    zp_var(i) = zp.var;
    
    if compute_LOO_res
        
        % Compute "raw" residual
        res(i) = zt - zp_mean(i);
        
        % Compute normalized residual
        if heteroscedastic
            res_norm(i) = res(i) / (sqrt (sigma(i)^2 + zp.var)); 
        else
            res_norm(i) = res(i) / (sqrt (sigma^2 + zp.var)); 
    end
end

% Prepare outputs
LOO_pred = stk_dataframe ([zp_mean zp_var], {'mean', 'var'});
if compute_LOO_res
    LOO_res.raw = res;
    LOO_res.normalized = res_norm;
end

end % function
