% STK_GET_OPTIMIZABLE_PARAMETERS [STK internal]
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

function value = stk_get_optimizable_parameters (param)

% This function will catch all calls to stk_get_optimizable_parameters for which
% param is not an object of a "parameter class" (more precisely, a class that
% implements stk_get_optimizable_parameters)

if ~ isnumeric (param)
    
    try
        
        % Extract parameter values
        param = param(:);
        
        % Note: if param is an object, the previous line is actually a call to
        % subsref in disguise.  This way of supporting parameter objects has
        % been introduced in STK 2.0.0 as an "experimental" feature. It is now
        % deprecated.
        
    catch
        
        stk_error (['stk_get_optimizable_parameters is not implemented for ' ...
            'objects of class ', class(param), '.'], 'TypeMismatch');
        
    end
    
end % if

% Make sure that the result is a column vector
value = param(:);

end % function
