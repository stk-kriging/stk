% STK_SET_OPTIMIZABLE_PARAMETERS changes the parameters of an object.
%
% CALL: MODEL = stk_set_optimizable_parameters (MODEL, VALUE)
%
%   sets to VALUE the 'optimizable_parameters' of the model, i.d., the
%   optimizable parameters of the covariance, the noise-variance (if there
%   are some) and the mean trend (future release).
%
% CALL: PARAM = stk_set_optimizable_parameters (PARAM, VALUE)
%
%    sets to VALUE the 'optimizable_parameters' property of PARAM.  The argument
%    VALUE is expected to be a numerical vector of the appropriate length.
%
% NOTE:
%
%    Numerical arrays are considered as a special kind of parameter object, for
%    which the 'optimizable_parameters' property is taken to be PARAM(:).
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal.  STK users that wish to
%    experiment with parameter classes can already overload it, but should be
%    aware that API-breaking changes are likely to happen in future releases.
%
% See also: stk_get_optimizable_parameters

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
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

function arg_out = stk_set_optimizable_parameters (arg1, value)

% This function will catch all calls to stk_set_optimizable_parameters for which
% neither param nor value is an object of a "parameter class" (more precisely,
% a class that implements stk_set_optimizable_parameters)

if isstruct(arg1) % is a model
    
    model = arg1;
    
    % Number of covariance parameters (assume there is always optimizable
    % covariance parameters)
    nb_param_cov = length(stk_get_optimizable_parameters(model.param));
    if stk_isnoisy(model)
        nb_param_lnv = length(stk_get_optimizable_parameters(model.lognoisevariance));
        
        % Check length of value
        if numel(value) ~= (nb_param_cov + nb_param_lnv)
            stk_error(['The length of the value must fit the number of',...
                ' parameters.'], 'IncorrectSize');
        end
        
        % Change covariance parameter
        model.param = stk_set_optimizable_parameters(...
            model.param, value(1:nb_param_cov));
        % Change noise variance parameter
        model.lognoisevariance = stk_set_optimizable_parameters(...
            model.lognoisevariance, value(nb_param_cov + (1:nb_param_lnv)));
    else
        % nb_param_lnv = 0
        % Check length of value
        if numel(value) ~= nb_param_cov
            stk_error(['The length of the value must fit the number of',...
                ' parameters.'], 'IncorrectSize');
        end
        
        % Change covariance parameter value
        model.param = stk_set_optimizable_parameters(model.param, value(:));
    end
    
    % The output is a model
    arg_out = model;
    
else % is something else (parameters ?)
    
    param = arg1;
    try
        
        % If param is numeric, the following syntax preserves its size and type
        param(:) = value;
        
        % Note: if param is an object, the previous line is actually a call to
        % subsasgn in disguise. This way of supporting parameter objects has been
        % introduced in STK 2.0.0 as an "experimental" feature. It is now
        % deprecated.
        
    catch
        
        stk_error (['stk_set_optimizable_parameters is not implemented for ' ...
            'objects of class ', class(param), '.'], 'TypeMismatch');
        
    end % if
    
    % The output is a parameter
    arg_out = param;
end

end % function
