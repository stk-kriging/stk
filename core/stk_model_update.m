% STK_MODEL_UPDATE updates a model with new data
%
% CALL: M_POSTERIOR = stk_model_update (M_PRIOR, X, Y)
%
%    updates model M_PRIOR with additional data (X, Y).  The result is an
%    stk_model_gpposterior object.
%
% See also: stk_model_gpposterior

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

function M_posterior = stk_model_update (M_prior, xi, zi)

M_posterior = stk_model_gpposterior (M_prior, xi, zi);

end % function

%!test
%! x1 = (linspace (0, 1, 15))';  z1 = sin (x1);
%! x2 = (linspace (2, 3, 15))';  z2 = sin (x2);
%! xt = (linspace (1, 2, 15))';  zt = sin (xt);
%!
%! % Prior model
%! M0 = stk_model ('stk_materncov32_iso');
%! M0.param = log ([1.0; 2.1]);
%!
%! M1 = stk_model_update (M0, x1, z1);
%! M1 = stk_model_update (M1, x2, z2);  % this calls @stk_model_gpposterior/...
%! zp1 = stk_predict (M1, xt);
%!
%! M2 = stk_model_gpposterior (M0, [x1; x2], [z1; z2]);
%! zp2 = stk_predict (M2, xt);
%!
%! assert (stk_isequal_tolabs (double (zp2 - zp1), zeros (15, 2), 1e-10))
