% STK_MODEL_UPDATE [overload STK function]

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

function M = stk_model_update (M, x_new, z_new, lnv_new)

lnv_current = M.prior_model.lognoisevariance;

if nargin < 4  % lnv not provided (homoscedastic case only)
    
    if ~ isscalar (lnv_current)
        stk_error (sprintf (['The fourth input argument is mandatory when ' ...
            'updating an heteroscedastic model.\n\nPlease use\n' ...
            '\n   M = stk_model_update (M, X_NEW, Z_NEW, LNV_NEW)\n\n'...
            'to provide the value LNV_NEW of the lognoisevariance at the ' ...
            'new observations points X_NEW.']), 'NotEnoughInputArguments');
    end
    
    heteroscedastic = false;
    
elseif ~ isempty (lnv_new)  % lnv provided (heteroscedastic case only)
    
    if (size (M.input_data, 1) ~= 1) && (isscalar (lnv_current))
        if lnv_current == -inf,
            s1 = 'a noiseless';
            s2 = 'noiseless';
        else
            s1 = 'an homoscedastic';
            s2 = 'homoscedastic';
        end
        stk_error (sprintf (['The fourth input argument should not be used ' ...
            'when updating %s model.\n\nPlease use\n\n   M = stk_model_' ...
            'update (M, X_NEW, Z_NEW)\nor M = stk_model_update (M, X_NEW, ' ...
            'Z_NEW, [])\n\nto update your %s model M with new data (X_NEW, ' ...
            'Z_NEW).'], s1, s2), 'NotEnoughInputArguments');
    end
    
    % Make sure that lnv is a column vector
    lnv_new = lnv_new(:);
    
    heteroscedastic = true;
end

M.input_data = [M.input_data; x_new];
M.output_data = [M.output_data; z_new];

if heteroscedastic
    M.prior_model.lognoisevariance = [lnv_current; lnv_new];
end

% FIXME: use @stk_kreq/stk_update ?
M.kreq = stk_kreq_qr (M.prior_model, M.input_data);

end % function


%!shared x_obs, z_obs, ref, M_prior, x_new, z_new, lnv_new
%! [x_obs, z_obs, ref] = stk_dataset_twobumps ('noisy2');
%! M_prior = stk_model ('stk_materncov52_iso');
%! M_prior.param = [-0.15; 0.38];
%! M_prior.lognoisevariance = 2 * log (ref.noise_std);
%! x_new = [-0.79; -0.79];
%! z_new = [-0.69; -0.85];
%! lnv_new = ref.noise_std_func (x_new);

%!test  % heteroscedastic
%! M_prior.lognoisevariance = 2 * log (ref.noise_std);
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! M_post = stk_model_update (M_post, x_new, z_new, lnv_new);

%!error  % using lnv_new / homoscedastic
%! M_prior.lognoisevariance = 0;
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! M_post = stk_model_update (M_post, x_new, z_new, lnv_new);  % NOT OK

%!error  % using lnv_new / noiseless
%! M_prior.lognoisevariance = -inf;
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs)
%! M_post = stk_model_update (M_post, x_new, z_new, lnv_new);  % NOT OK

%!error  % not using lnv_new / heteroscedastic
%! M_prior.lognoisevariance = 2 * log (ref.noise_std);
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%! M_post = stk_model_update (M_post, x_new, z_new);
