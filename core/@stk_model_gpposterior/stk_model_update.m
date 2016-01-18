% STK_MODEL_UPDATE [overload STK function]

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

function M = stk_model_update (M, xi, zi)

M.input_data = [M.input_data; double(xi)];
M.output_data = [M.output_data; double(zi)];

% FIXME: use @stk_kreq/stk_update ?
M.kreq = stk_kreq_qr (M.prior_model, M.input_data);

end % function


%!test M_prior, x_obs, z_obs
%! x1 = (linspace (0, 1, 15))';
%! z1 = sin (x1);
%! x2 = (linspace (1, 2, 15))';
%! z2 = sin (x2);
%! M_prior = stk_model ('stk_materncov32_iso');
%! M_prior.order = 0; % this is currently the default, but better safe than sorry
%! M_prior.param = log ([1.0; 2.1]);

%!error M_post = stk_model_gpposterior (M_prior, x_obs, [z_obs; z_obs]);
