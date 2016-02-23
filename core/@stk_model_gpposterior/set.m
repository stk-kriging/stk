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
    
    case 'param'
        model.prior_model.param = value;
        
    case 'lognoisevariance'
        model.prior_model.lognoisevariance = value;
        
    case {'input_dim', 'output_dim', 'dim'}
        % Note: 'dim' is kept for consistency with 'model structures'
        %   (prior models described as ordinary structures, that is)
        stk_error (sprintf ('Property %s is read-only.\n', ...
            propname), 'ReadOnlyProperty');
        
    otherwise
        try
            model.(propname) = value;
        catch
            if (~ ischar (propname))
                stk_error ('Invalid property name.', 'InvalidArgument');
            elseif (ischar (propname)) && (~ isfield (model, propname))
                errmsg = sprintf ('There is no field named %s.', propname);
                stk_error (errmsg, 'InvalidArgument');
            else
                rethrow (lasterror ());
            end
        end
        
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