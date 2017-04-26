% STK_MODEL_FIXLM  [STK internal]
%
% This internal STK function ensures backward compatiblity for model structures
% with a .order field.

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

function model = stk_model_fixlm (model)

if isfield (model, 'lm')  % Modern style: .lm field
    
    if isfield (model, 'order')
        
        % If model.order is also present, it should be NaN
        if ~ isnan (model.order)
            
            % We also tolerate the case where model.order is compatible with
            % model.lm  (i.e., model.lm is a polynomial trend object, with the
            % appropriate degree.
            if ((model.order == -1) && (isa (model.lm, 'stk_lm_null'))) ...
                    || ((model.order ==  0) && (isa (model.lm, 'stk_lm_constant'))) ...
                    || ((model.order ==  1) && (isa (model.lm, 'stk_lm_affine'))) ...
                    || ((model.order ==  2) && (isa (model.lm, 'stk_lm_quadratic'))) ...
                    || ((model.order ==  3) && (isa (model.lm, 'stk_lm_cubic')))
                
                model.order = nan;
                
            else
                
                stk_error (sprintf (['Invalid model structure: both '       ...
                    'model.lm and model.order are present, and their '      ...
                    'values are not compatible.\nThe ''.order'' field '     ...
                    'is deprecated, please consider using ''.lm'' only.']), ...
                    'InvalidArgument');
                
            end
            
        end % if ~ isnan (model.order)
        
        model = rmfield (model, 'order');
        
    end % if isfield (model.order)
    
elseif isfield (model, 'order')  % Old style: .order field only
    
    model.lm = stk_lm_polynomial (model.order);
    model = rmfield (model, 'order');
    
else  % Assume constant mean when neither .order nor .lm is present
    
    model.lm = stk_lm_constant ();
    
end

end % function
