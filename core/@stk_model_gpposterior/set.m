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
        % by-passing set_prior_model, since no argument checking is done there
        model.prior_model = value;
        
        
    case 'param'  % alias for prior_model.param
        % by-passing set_param, since no argument checking is done there
        model.prior_model.param = value;
        
    case 'lognoisevariance'  % alias for prior_model.lognoisevariance
        model = set_lognoisevariance (model, value, false);
        
    case {'input_dim', 'output_dim', 'dim'}
        % Note: 'dim' is kept for consistency with 'model structures'
        %   (prior models described as ordinary structures, that is)
        errmsg = sprintf ('Property %s is read-only.\n', propname);
        stk_error (errmsg, 'ReadOnlyProperty');
        
    case {'input_data', 'output_data'}
        stk_error (sprintf (['Property %s is read-only.  Use ' ...
            'stk_model_update to add new evaluations results ' ...
            'to an existing stk_model_gpposterior object.'], ...
            propname), 'ReadOnlyProperty');
        
    otherwise
        if (~ ischar (propname))
            stk_error ('Invalid property name.', 'InvalidArgument');
        elseif (ischar (propname)) && (~ isfield (model, propname))
            errmsg = sprintf ('There is no field named %s.', propname);
            stk_error (errmsg, 'InvalidArgument');
        end
        
end % switch

% Update kreq field: recompute QR factorization
model.kreq = stk_kreq_qr (model.prior_model, model.input_data);

end % function

%#ok<*CTCH,*LERR>


%!shared M_post
%! x_obs = (linspace (0, pi, 15))';
%! z_obs = sin (x_obs);
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.order = 0; % this is currently the default, but better safe than sorry
%! M_prior.param = log ([1.0; 2.1]);
%! M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);

%!error value = get (M_post, 1.33);
%!error value = get (M_post, 'dudule');
%!test  value = get (M_post, 'prior_model');
