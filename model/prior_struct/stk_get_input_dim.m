% STK_GET_INPUT_DIM returns the input dimension of a model or stk_iodata object
%
% CALL: INPUT_DIM = stk_get_input_dim (MODEL)
%
%    returns the input dimension INPUT_DIM of the MODEL.
%
% CALL: INPUT_DIM = stk_get_input_dim (DATA)
%
%    returns the input dimension INPUT_DIM of the stk_iodata object DATA,
%    i.e. the number of variables in the input data.
%
% See also: stk_get_input_data, stk_get_output_dim

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

function input_dim = stk_get_input_dim (model)

stk_assert_model_struct (model);

if isfield (model, 'dim')
    
    input_dim = model.dim;
    
else
    
    if ischar (model.covariance_type)
        covariance_name = model.covariance_type;
    else
        % Assume that model.covariance_type is a handle
        covariance_name = func2str (model.covariance_type);
    end
    
    switch covariance_name
        
        % Anisotropic Matern covariance function with unknown regularity
        case 'stk_materncov_aniso'
            input_dim = length (model.param) - 2;
            
            % Other anisotropic covariance functions
        case {'stk_expcov_aniso',      'stk_materncov32_aniso', ...
              'stk_materncov52_aniso', 'stk_gausscov_aniso',    ...
              'stk_sphcov_aniso'}
            input_dim = length (model.param) - 1;
            
        otherwise
            stk_error ('Unable to guess input dimension', 'IncorrectArgument');
    end
    
end

end % function
