% GET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
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

function value = get (model, propname)

switch propname
    
    case {'prior_model', 'input_data', 'output_data', 'kreq'}
        % rem: kreq is a hidden property
        value = model.(propname);
        
    otherwise
        if ~ ischar (propname)
            errmsg = 'Invalid property name.';
        else
            errmsg = sprintf ('There is no field named %s.', propname);
        end
        stk_error (errmsg, 'InvalidArgument');
        
end % switch

end % function

%#ok<*CTCH,*LERR>


%!shared M_post
%! x_obs = (linspace (0, pi, 15))';
%! z_obs = sin (x_obs);
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);

%!error value = get (M_post, 1.33);
%!error value = get (M_post, 'dudule');
%!test  value = get (M_post, 'prior_model');
