% STK_GET_OUTPUT_DATA returns the output data of a model
%
% CALL: OUTPUT_DATA = stk_get_output_data (MODEL)
%
%    returns the OUTPUT_DATA of the MODEL (which is empty if MODEL is
%    a prior model).
%
% See also: stk_get_input_data, stk_get_prior_model

% Copyright Notice
%
%    Copyright (C) 2017, 2018 CentraleSupelec
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

function output_data = stk_get_output_data (model)

stk_assert_model_struct (model);

output_data = zeros (0, 1);

end % function
