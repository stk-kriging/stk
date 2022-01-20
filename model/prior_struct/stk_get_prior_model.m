% STK_GET_PRIOR_MODEL returns the underlying prior model of a model
%
% CALL: PRIOR_MODEL = stk_get_prior_model (MODEL)
%
%    returns the underlying PRIOR_MODEL of the MODEL (which is equal to MODEL
%    itself if MODEL is a prior model).
%
% See also: stk_get_input_data, stk_get_output_data

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

function prior_model = stk_get_prior_model (model)

stk_assert_model_struct (model);

prior_model = model;

end % function
