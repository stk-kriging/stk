% STK_GAUSSIANNOISE_HET0 [experimental] is an example of noise model
%
% CALL: GN = stk_gaussiannoise_het0 (VF, PHI)
%
%    creates an heteroscedastic Gaussian noise model with variance function VF
%    and dispersion PHI.  The variance at location x is given by:
%
%       tau^2 (x) = PHI * VF(x).
%
% OPTIMIZABLE PARAMETER:
%
%    PARAM(1) = log (PHI)
%
% REMARK:
%
%    The suffix "0" in the name of the class indicates that there are no
%    additional hyperparameters in the definition of the variance function
%    (in other words, the only hyperparameter is the dispersion).
%
%    This class can be used as an example of how to create noise model objects
%    by subclassing stk_gaussiannoise_.
%
% EXPERIMENTAL CLASS WARNING:  The stk_gaussiannoise_het0 class is
%    currently considered experimental.  STK users who wish to experiment with
%    it are welcome to do so, but should be aware that API-breaking changes
%    are likely to happen in future releases.  We invite them to direct any
%    questions, remarks or comments about this experimental class to the STK
%    mailing list.

% Copyright Notice
%
%    Copyright (C) 2018-2020 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function gn = stk_gaussiannoise_het0 (variance_function, dispersion)

if (nargin < 2) || (isempty (dispersion))
    log_dispersion = nan;  % must be estimated
    
    if nargin == 0
        variance_function = @(x) 1.0;
    end
else
    log_dispersion = log (dispersion);
end

gn.log_dispersion = log_dispersion;
gn.variance_function = variance_function;

gn = class (gn, 'stk_gaussiannoise_het0', stk_gaussiannoise_ ());

end % function
