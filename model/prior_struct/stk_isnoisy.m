% STK_ISNOISY returns false for noiseless models, true otherwise
%
% CALL: ISNOISY = stk_isnoisy (MODEL)
%
%    returns false for a noiseless MODEL and true otherwise.
%
%    MODEL is considered noiseless if:
%
%     * MODEL.lognoisevariance is missing or empty  (for backward compatibility
%       with previous versions of STK where the lognoisevariance field was
%       optional),
%
%     * MODEL.lognoisevariance is equal to -inf  (this is the default for a
%       model created by stk_model and the currently recommended way to declare
%       a noiseless model),
%
%     * MODEL.lognoisevariance is a vector of -inf  (heteroscedastic case with
%       all variances set to zero).
%
% REMARK: Variance model objects
%
%    Note that in the case where MODEL.lognoisevariance is an object, the MODEL
%    is automatically considered noisy, even when the parameters of the variance
%    model are set (or can be set) to values such that the noise variance
%    function vanishes.
%
% See also: stk_model

% Copyright Notice
%
%    Copyright (C) 2016-2018, 2020 CentraleSupelec
%    Copyright (C) 2017-2018 LNE
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Remi Stroh   <remi.stroh@lne.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function b = stk_isnoisy (model)

if (~ isfield (model, 'lognoisevariance')) || (isempty (model.lognoisevariance))
    
    % Backward compatiblity: accept model structures with missing
    % lognoisevariance, and consider them as noiseless models
    
    b = false;
    
else
    
    b = ~ (isnumeric (model.lognoisevariance) ...
        && (all (model.lognoisevariance == - inf)));
    
end

end % function
