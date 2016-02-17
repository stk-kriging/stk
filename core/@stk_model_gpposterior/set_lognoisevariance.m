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

function model = set_lognoisevariance (model, lnv)

% Check lnv
if ~ isscalar (lnv)    
    n = size (model.input_data, 1);
    if (~ isvector (lnv)) || (length (lnv) ~= n)
        stk_error (['lnv must be either a scalar or a vector' ...
            ' of length size (xi, 1).'], 'InvalidArgument');
    end    
    % Make sure that lnv is a column vector
    lnv = lnv(:);
end

model.prior_model.lognoisevariance = lnv;

end % function
