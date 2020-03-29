% STK_GET_OUTPUT_DIM returns the output dimension of a model or stk_iodata object
%
% CALL: OUTPUT_DIM = stk_get_output_dim (MODEL)
%
%    returns the output dimension OUTPUT_DIM of the MODEL.  (Currently, only
%    one-dimensional models are supported in STK, but this might change in
%    the future.)
%
% CALL: OUTPUT_DIM = stk_get_output_dim (DATA)
%
%    returns the output dimension INPUT_DIM of the stk_iodata object DATA,
%    i.e. the number of variables in the output data.
%
% See also: stk_get_output_data, stk_get_input_dim

% Copyright Notice
%
%    Copyright (C) 2020 CentraleSupelec
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

function output_dim = stk_get_output_dim (model)

stk_assert_model_struct (model);

output_dim = 1;

end % function
