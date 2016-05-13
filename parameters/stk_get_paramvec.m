% STK_GET_PARAMVEC returns the value of property 'paramvec'
%
% CALL: PARAMVEC = stk_get_paramvec (PARAM)
%
%    returns the value of property 'paramvec' for parameter object PARAM, which
%    is a column vector numerical parameters.
%
% NOTE:
%
%    Numerical arrays are considered as a special kind of parameter object, for
%    which the vector of numerical parameter is taken to be PARAM(:).
%
% See also: stk_set_paramvec

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

function paramvec = stk_get_paramvec (param)

% This function will catch all calls to get_paramvec for which param is not
% an object of a "parameter class" (more precisely, a class that implements
% get_paramvec)

if isnumeric (param)
    
    % Make sure that the result is a column vector
    paramvec = param(:);
    
elseif isobject (param) && ismethod (param, 'subsref') % Backward compat.
    
    % This way of supporting parameter objects has been introduced in STK 2.0.0
    % as an "experimental" feature. It is now deprecated.
    
    % Call subsasgn
    paramvec = param(:);
    
    % Make sure that the result is a column vector
    paramvec = paramvec(:);
    
else
    
    stk_error (['get_paramvec is not implemented for objects of class ', ...
        class (param), '.'], 'TypeMismatch');
    
end % if

end % function
