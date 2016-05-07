% SET_PARAM sets the parameters of the covariance function

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

function model = set_prior_model (model, prior_model, recompute)

% Make sure that lognoisevariance is -inf for noiseless models
if ~ stk_isnoisy (prior_model)
    prior_model.lognoisevariance = -inf;
end

% Backward compatibility:
%   accept model structures with missing 'dim' field
if (~ isfield (prior_model, 'dim')) || (isempty (prior_model.dim))
    prior_model.dim = size (model.input_data, 2);
end

% Check M_prior.lognoisevariance
if ~ isscalar (prior_model.lognoisevariance)
    if (~ isvector (prior_model.lognoisevariance)) && (length ...
            (prior_model.lognoisevariance) == size (model.input_data, 1))
        stk_error (['M_prior.lognoisevariance must be either ' ...
            'a scalar or a vector of length size (model.input_data, 1).'], ...
            'InvalidArgument');
    end
    % Make sure that lnv is a column vector
    prior_model.lognoisevariance = prior_model.lognoisevariance(:);
end

% Set prior_model field
model.prior_model = prior_model;

% Update kreq field: recompute QR factorization
if (nargin < 3) || (recompute)
    model.kreq = stk_kreq_qr (model.prior_model, model.input_data);
end

end % function
