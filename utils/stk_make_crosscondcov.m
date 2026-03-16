% STK_MAKE_CROSSCONDCOV computes a posterior cross covariance matrix.
%
% CALL: K = stk_make_crosscondcov (MODEL, XN, ZN, XT, X0)
%
%    computes the cross posterior covariance matrix K  for the model
%    MODEL between the sets of points XT and X0, given observations poibts 
%    XN, and observations ZN.

% Copyright Notice
%
%    Copyright (C) 2025 CentraleSupelec
%
%    Authors:  Romain Ait Abdelmalek-Lomenech   <romain.ait@centralesupelec.fr>
%              Julien Bect                      <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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


function K = stk_make_crosscondcov(model, xn, zn, xt, x0)

prior_model = model;
post_model = stk_model_gpposterior (model, xn, zn);
kreq1 = stk_make_kreq (post_model, xt);
kreq2 = stk_make_kreq (post_model, x0);

%prior_model = stk_get_prior_model (model);
prior_cov = stk_make_matcov (prior_model, xt, x0);

delta_cov = (get (kreq1, 'lambda_mu'))' * (get (kreq2, 'RS'));
K = prior_cov - delta_cov;

end