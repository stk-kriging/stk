% STK_GET_OPTIMIZABLE_PARAMETERS returns the parameters of the input.
%
% CALL: VALUE = stk_get_optimizable_parameters (MODEL)
%
%   returns the value of the 'optimizable_parameters' of the model, i.d.,
%   the optimizable parameters of the covariance, the noise-variance (if
%   there are some) and the mean trend (future release).
%
% CALL: VALUE = stk_get_optimizable_parameters (PARAM)
%
%    returns the value of the 'optimizable_parameters' property of PARAM.
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
% See also: stk_set_optimizable_parameters

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

function value = stk_get_optimizable_parameters (arg1)

% This function will catch all calls to stk_get_optimizable_parameters for which
% param is not an object of a "parameter class" (more precisely, a class that
% implements stk_get_optimizable_parameters)

if ~ isnumeric (arg1)
    
    if isstruct(arg1) % is a model
        model = arg1;
        
        if stk_isnoisy(model) % if there is noise, returns both parameters
            value = [stk_get_optimizable_parameters(model.param);
                stk_get_optimizable_parameters(model.lognoisevariance);];
        else % returns only covariance parameters
            value = stk_get_optimizable_parameters(model.param);
        end
        % TO DO: use prior to select the optimizable parameters.
        
    else % is something else (parameters ?)
        
        try
            
            % Extract parameter values
            value = arg1(:);
            
            % Note: if param is an object, the previous line is actually a call to
            % subsref in disguise.  This way of supporting parameter objects has
            % been introduced in STK 2.0.0 as an "experimental" feature. It is now
            % deprecated.
            
        catch
            
            stk_error (['stk_get_optimizable_parameters is not implemented for ' ...
                'objects of class ', class(arg1), '.'], 'TypeMismatch');
            
        end
        
    end
    
else % is numeric
    value = arg1;
end % if

% Make sure that the result is a column vector
value = value(:);

end % function
