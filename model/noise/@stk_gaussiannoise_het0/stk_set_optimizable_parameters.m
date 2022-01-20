% STK_SET_OPTIMIZABLE_PARAMETERS [overload STK internal]
%
% See also: stk_get_optimizable_parameters

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

function gn = stk_set_optimizable_parameters (gn, value)

if isa (gn, 'stk_gaussiannoise_het0')
    
    if isa (value, 'stk_gaussiannoise_het0')
        
        gn.variance_function = value.variance_function;
        gn.log_dispersion = value.log_dispersion;
        
    else
        
        % This form of assignment preserves the size and type of gn.log_dispersion
        gn.log_dispersion(:) = value;
        
    end
    
else
    
    stk_error (['The first input argument was expected to be an ' ...
        'object of class stk_gaussiannoise_het0'], 'TypeMismatch');
    
end

end % function
