% STK_PARAM_GETBLOCKSELECTORS [STK internal]
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal, don't rely on it
%    directly.  API-breaking changes are likely to happen in future releases.

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function select = stk_param_getblockselectors (model)

select = cell (2, 1);

% Covariance parameters
covparam = stk_get_optimizable_parameters (model.param);
covparam_size = length (covparam);
select{1} = true (covparam_size, 1);

% Noise parameters
noiseparam = stk_get_optimizable_noise_parameters (model);
noiseparam_size = length (noiseparam);
select{2} = true (noiseparam_size, 1);

end % function
