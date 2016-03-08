% SET_LOGNOISEVARIANCE sets the log of the variance of the noise

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

function model = set_lognoisevariance (model, lnv, recompute)

% Check lnv
if ~ isscalar (lnv)
    
    % Number of observations
    n = size (model.input_data, 1);
        
    if (~ isvector (lnv)) || (length (lnv) ~= n)        
        stk_error (sprintf (['lnv must be either a scalar or a vector ' ...
            'of length n=%d (the number of observations).\n\nHere, ' ...
            'size (lnv) = [%s].'], n, num2str (size (lnv))), 'InvalidArgument');
    end
    
    % Make sure that lnv is a column vector
    lnv = reshape (lnv, n, 1);
end

model.prior_model.lognoisevariance = lnv;

% Update kreq field: recompute QR factorization
if (nargin < 3) || (recompute)
    model.kreq = stk_kreq_qr (model.prior_model, model.input_data);
end

end % function


%!shared x_obs, z_obs, ref, M_prior
%! [x_obs, z_obs, ref] = stk_dataset_twobumps ('noisy2');
%! M_prior = stk_model ('stk_materncov52_iso');
%! M_prior.param = [-0.15; 0.38];
%! M_prior.lognoisevariance = 2 * log (ref.noise_std);

%!assert (~ isscalar (ref.noise_std));  % heteroscedastic dataset

%!test  % homoscedastic case
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! M_post.lognoisevariance = 0;  % scalar lnv, OK

%!test  % heteroscedastic case
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! M_post.lognoisevariance = 2 * log (ref.noise_std);

%!error  % lnv vector too long
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! x_new = [-0.79; -0.79];
%! z_new = [-0.69; -0.85];
%! lnv_new = ref.noise_std_func (x_new);
%! M_post.lognoisevariance(end + (1:2)) = lnv_new;  % NOT OK

%!error  % lnv vector too short
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! M_post.lognoisevariance = ref.noise_std(1:end-1);  % NOT OK

