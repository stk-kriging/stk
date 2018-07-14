% STK_GET_OBSERVATION_VARIANCES returns the variance of the observations
%
% CALL: V = stk_get_observation_variances (MODEL)
%
%    returns the variance of the observations for the posterior MODEL,
%    which must be an object of class @stk_model_gpposterior.
%
% CALL: V = stk_get_observation_variances (MODEL, XI)
%
%    returns the variance of the observations that would be obtained at
%    locations XI according to the prior MODEL, which must be a model structure
%    (see stk_model).
%
% See also: stk_model.

% Copyright Notice
%
%    Copyright (C) 2017, 2018 CentraleSupelec
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

function v = stk_get_observation_variances (model, xi)

% Just a quick check
if ~ (isstruct (model) && isfield (model, 'param'))
    stk_error (['The first input argument does not look like a ' ...
        'valid STK model structure.'], 'InvalidArgument');
end

ni = size (xi, 1);

if ~ stk_isnoisy (model)  % Noiseless case
    
    v = zeros (ni, 1);
    
else  % Noisy case
    
    if isnumeric (model.lognoisevariance)
        
        % Classical STK: model.lognoisevariance is numeric
        v = exp (model.lognoisevariance);
        
        if isscalar (v)
            v = repmat (v, ni, 1);
        end
        
    else  % Object-oriented approach
        
        % FIXME: Think harder about function names... are we really going to
        % have a function named stk_noisevar_matrix ?
        
        v = stk_noisevar_matrix (model.lognoisevariance, xi, -1, true);
        
    end
    
end

end % function
