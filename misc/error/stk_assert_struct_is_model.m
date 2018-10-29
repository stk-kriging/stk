% STK_ASSERT_STRUCT_IS_MODEL [STK internal]
%
% INTERNAL FUNCTION WARNING:
%    This function is currently considered as internal: API-breaking changes are
%    likely to happen in future releases.  Please don't rely on it directly.
%
% See also: stk_model

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

function stk_assert_struct_is_model (model)

% Just a quick check
if isstruct (model) && ~ isfield (model, 'param')
    
    stk_error (['The input argument does not look like a valid STK model' ...
        'structure.'], 'InvalidArgument');
    
end

end % function
