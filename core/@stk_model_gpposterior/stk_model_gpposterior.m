% STK_MODEL_GPPOSTERIOR constructs a posterior model

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

function model = stk_model_gpposterior (prior_model, xi, zi)

if nargin == 3
    
    if iscell (xi)
        % Legacy support for experimental hidden feature, to be removed
        kreq = xi{2};  xi = xi{1};
    else
        kreq = [];
    end
    
    % Check the size of zi
    n = size (xi, 1);
    if ~ (isempty (zi) || isequal (size (zi), [n 1]))
        stk_error (['zi must either be empty or have the ' ...
            'same number of rows as x_obs.'], 'IncorrectSize');
    end
    
elseif nargin == 0
    
    prior_model = [];
    xi = [];
    zi = [];
    kreq = [];
    
else
    stk_error ('Incorrect number of input arguments.', 'SyntaxError');
end

% Prepare object fields
model.prior_model  = [];
model.input_data   = xi;
model.output_data  = zi;
model.kreq         = kreq;

% Create object
model = class (model, 'stk_model_gpposterior');

% Set prior model
if ~ isempty (prior_model)
    if isempty (kreq)
        model = set_prior_model (model, prior_model);
    else
        % Legacy support for experimental hidden feature (continued)
        model = set_prior_model (model, prior_model, false);
    end
end

end % function


%!shared M_prior, x_obs, z_obs
%! x_obs = (linspace (0, pi, 15))';
%! z_obs = sin (x_obs);
%!
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);

%!test  M_post = stk_model_gpposterior ();
%!test  M_post = stk_model_gpposterior (M_prior, x_obs, z_obs);
%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs]);
%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs], 3.441);

%!test % hidden feature
%! kreq = stk_kreq_qr (M_prior, x_obs);
%! M_post = stk_model_gpposterior (M_prior, {x_obs, kreq}, z_obs);
