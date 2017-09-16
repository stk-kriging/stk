% STK_PREDICT_LEAVEONEOUT computes LOO predictions and residuals
%
% CALL: LOO_PRED = stk_predict_leaveoneout (M_PRIOR, XI, ZI)
%
%    computes LOO predictions for (XI, ZI) using the prior model M_PRIOR.  The
%    result is a dataframe with n rows and two columns, where n is the common
%    number of rows of XI and ZI.  The first column is named 'mean' and contains
%    LOO prediction means.  The second column is named 'var' and contains LOO
%    prediction variances.
%
% CALL: [LOO_PRED, LOO_RES] = stk_predict_leaveoneout (M_PRIOR, XI, ZI)
%
%    also returns LOO residuals.  The result LOO_RES is a dataframe with n rows
%    and two columns.  The first column is named 'residuals' and contains raw
%    (i.e., unnormalized) residuals.  The second column is named 'norm_res' and
%    contains normalized residuals.
%
% CALL: [LOO_PRED, LOO_RES] = stk_predict_leaveoneout (M_POST)
%
%    does the same as above using a posterior model object M_POST directly.
%
% CALL: stk_predict_leaveoneout (...)
%
%    automatically produces LOO cross-validations plots in the current figure,
%    using stk_plot_predvsobs (left panel) and stk_plot_histnormres (right
%    panel).
%
% REMARK
%
%    This function actually computes pseudo-LOO prediction and residuals,
%    where the same parameter vector is used for all data points.
%
% See also stk_example_kb10, stk_plot_predvsobs, stk_plot_histnormres

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
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

function varargout = stk_predict_leaveoneout (M_prior, xi, zi)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

M_post = stk_model_gpposterior (M_prior, xi, zi);

if nargout == 0
    
    % Call stk_predict_leaveoneout with nargout == 0 to create the plots
    stk_predict_leaveoneout (M_post);
    
else
    
    varargout = cell (1, nargout);
    [varargout{:}] = stk_predict_leaveoneout (M_post);
    
end

end % function


%!shared n, x_obs, z_obs, model
%! n = 20;
%! x_obs = stk_sampling_regulargrid (n, 1, [0; 2*pi]);
%! z_obs = stk_feval (@sin, x_obs);
%! model = stk_model ('stk_materncov32_iso');
%! model.param = log ([1; 5]);

%!test  % one output
%!
%! loo_pred = stk_predict_leaveoneout (model, x_obs, z_obs);
%!
%! assert (isequal (size (loo_pred), [n 2]));
%! assert (isequal (loo_pred.colnames, {'mean', 'var'}));
%! assert (all (isfinite (loo_pred(:))));

%!test  % two outputs
%!
%! [loo_pred, loo_res] = stk_predict_leaveoneout (model, x_obs, z_obs);
%!
%! assert (isequal (size (loo_pred), [n 2]));
%! assert (isequal (loo_pred.colnames, {'mean', 'var'}));
%! assert (all (isfinite (loo_pred(:))));
%!
%! assert (isequal (size (loo_res), [n 2]));
%! assert (isequal (loo_res.colnames, {'residuals', 'norm_res'}));
%! assert (all (isfinite (loo_res(:))));

%!test  % heteroscedastic noise case
%!
%! model.lognoisevariance = (1 + rand (n, 1)) * 1e-6;
%! [loo_pred, loo_res] = stk_predict_leaveoneout (model, x_obs, z_obs);
%!
%! assert (isequal (size (loo_pred), [n 2]));
%! assert (isequal (loo_pred.colnames, {'mean', 'var'}));
%! assert (all (isfinite (loo_pred(:))));
%!
%! assert (isequal (size (loo_res), [n 2]));
%! assert (isequal (loo_res.colnames, {'residuals', 'norm_res'}));
%! assert (all (isfinite (loo_res(:))));
