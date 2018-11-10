% STK_GET_INTPUT_DATA [overload STK function]

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

function input_data = stk_get_input_data (model)  %#ok<INUSD>

% DESIGN NOTE: all model classes derived from stk_model_base are considered
% as prior models unless they overload stk_get_prior_model, stk_get_input_data
% stk_get_output_data and stk_get_observation_variances.

% FIXME: size should be 0 x input_dim

input_data = [];

end % function
