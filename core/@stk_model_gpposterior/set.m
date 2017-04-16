% SET [overload base function]

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

function model = set (model, propname, value)

switch propname
    
    case 'prior_model'
        stk_error (sprintf (['Property prior_model is read-only.\n\nHINT: ' ...
            'Construct a new stk_model_gpposterior object if you need to ' ...
            'change the prior model.']), 'ReadOnlyProperty');
        
    case 'kreq'
        % rem: kreq is a hidden property
        stk_error (sprintf (['Property kreq is a hidden, read-only ' ...
            'property.\n\nHINT: Don''t try to set kreq directly. It will ' ...
            'be updated automatically whenever it is needed.']), ...
            'ReadOnlyProperty');
        
    case {'input_data', 'output_data'}
        stk_error (sprintf (['Property %s is read-only.\n\nHINT: Use ' ...
            'stk_model_update to add new evaluations results ' ...
            'to an existing stk_model_gpposterior object.'], ...
            propname), 'ReadOnlyProperty');
        
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
