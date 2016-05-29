% STK_SET_PARAMVEC [internal] sets the value of property 'paramvec'
%
% CALL: PARAM = stk_set_paramvec (PARAM, PARAMVEC)
%
%    sets the numerical parameter property 'paramvec' of parameter object PARAM
%    to the value PARAMVEC.
%
% NOTE:
%
%    Numerical arrays are considered as a special kind of parameter object, for
%    which the 'paramvec' property is taken to be PARAM(:).
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal, which is why it is
%    located in a private directory.  STK users that which to experiment with
%    parameter classes can already overload it, but should be aware that
%    API-breaking changes are likely to happen in future releases of STK.
%
% See also: stk_get_paramvec

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function param = stk_set_paramvec (param, paramvec)

% This function will catch all calls to set_paramvec for which neither param
% nor value is an object of a "parameter class" (more precisely, a class that
% implements set_paramvec)

if isnumeric (param) ...
        || (isobject (param) && ismethod (param, 'subsasgn')) % Backward compat.
    
    % If param is numeric, we preserve its size and type of param:
    param(:) = paramvec;
    
    % Note: if param is an object, the previous line is actually a call to
    % subsasgn in disguise. This way of supporting parameter objects has been
    % introduced in STK 2.0.0 as an "experimental" feature. It is now
    % deprecated.
    
else
    
    stk_error (['set_paramvec is not implemented for objects of class ', ...
        class (param), '.'], 'TypeMismatch');
    
end % if

end % function
