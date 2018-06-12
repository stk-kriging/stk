% STK_PARAM_ESTIM_WITHREP ...

% Copyright Notice
%
%    Copyright (C) 2015, 2018 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function [param, lnv] = stk_param_estim_withrep (model, xi, zi)

% NOTE: the fact that we need to write such a function shows that
%   we should have a dedicated class for these three-columnd dataframes
%   for which we could implement stk_param_estim (and probably other
%   things too)

switch size (zi, 2)
    
    case 1,  % The usual one-column representation of evaluation results
        
        [param, lnv] = stk_param_estim (model, xi, zi);
        
    case 3,  % Three-column representation of evaluation results
        lnv = model.lognoisevariance;
        
        if (isscalar (lnv)) && (lnv == -inf) && (~ all (zi.nb_obs == 1))
            
            stk_error (['Three-column representation of evaluations with ' ...
                'repetitions is not supported in the noiseless case.'], ...
                'IncompatibleArguments');

        elseif (any (isnan (lnv)))
            
            stk_error (['Three-column representation of evaluations with ' ...
                'repetitions is not supported yet when the variance of the ' ...
                'noise in unknown.'], 'IncompatibleArguments');

        else % This works in all remaining cases
            
            model.lognoisevariance = lnv - (log (zi.nb_obs));
            
        end
                
        param = stk_param_estim (model, xi, zi.mean);
        
    otherwise
        error ('Ooops.  I don''t know how to handle this case.');
        
end % switch

end % function
