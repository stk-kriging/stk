% STK_REPLICATE_OBS_NOISE [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015, 2017, 2018 CentraleSupelec
%    Copyright (C) 2017 LNE
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Remi Stroh   <remi.stroh@lne.fr>

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

function noise_sim = stk_replicate_obs_noise (model, xi, nrep)

stk_assert_model_struct (model);

ni = size (xi, 1);

if ~ stk_isnoisy (model)  % Noiseless case
    
    noise_sim = zeros (ni, nrep);
    
else  % Noisy case
    
    % Standard deviation of the observations
    s = sqrt (stk_covmat_noise (model, xi, [], -1, true));
    
    % Simulate noise values
    if isscalar (s)
        % Homoscedastic case
        noise_sim = s * randn (ni, nrep);
    else
        % Heteroscedastic case
        s = reshape (s, ni, 1);
        noise_sim = bsxfun (@times, s, randn (ni, nrep));
    end
    
end

end % function
