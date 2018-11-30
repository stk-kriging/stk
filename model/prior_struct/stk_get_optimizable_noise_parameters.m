% STK_GET_OPTIMIZABLE_NOISE_PARAMETERS [STK internal]

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%    Copyright (C) 2018 LNE
%
%    Authors:  Remi Stroh   <remi.stroh@lne.fr>
%              Julien Bect  <julien.bect@centralesupelec.fr>

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

function [noiseparam, isnoisy] = stk_get_optimizable_noise_parameters (model)

stk_assert_model_struct (model);

isnoisy = stk_isnoisy (model);

if isnoisy
    
    noiseparam = model.lognoisevariance;
    
    if isnumeric (noiseparam)
        
        if ~ isscalar (noiseparam)
            % Old-style heteroscedastic case: don't optimize
            noiseparam = [];
        end
        
    else  % model.lognoisevariance is a parameter object
        
        noiseparam = stk_get_optimizable_parameters (noiseparam);
        
    end
    
else
    
    noiseparam = [];
    
end

end % function
