% STK_SAMPCRIT_EI_EVAL computes the EI criterion
%
% CALL: EI = stk_sampcrit_ei_eval (ZP_MEAN, ZP_STD, ZI)
%
%    computes the value EI of the Expected Improvement (EI) criterion for a
%    minimization problem, with respect to the observed values ZI, assuming
%    Gaussian predictive distributions with means ZP_MEAN and standard
%    deviations ZP_STD.  The input argument must have the following sizes:
%
%       * ZP_MEAN    M x 1,
%       * ZP_STD     M x 1,
%       * ZI         N x 1,
%
%    where M is the number of points where the EI must be computed, and N the
%    number of observations.  The output has size M x 1.
%
% REMARK
%
%    Since the EI is computed for a minimization problem, the result depends
%    on the minimum of the obervations only, not on the entire set of observed
%    values.  The above call is thus equivalent to
%
%       EI = stk_sampcrit_ei_eval (ZP_MEAN, ZP_STD, min (ZI))
%
% NOTE
%
%    This function was added in STK 2.4.1, and will in the future completely
%    replace stk_distrib_normal_ei.  Note that, unlike the present function,
%    stk_distrib_normal_ei returns as a default the EI for a *maximization*
%    problem.
%
% REFERENCES
%
%   [1] D. R. Jones, M. Schonlau and William J. Welch. Efficient global
%       optimization of expensive black-box functions.  Journal of Global
%       Optimization, 13(4):455-492, 1998.
%
%   [2] J. Mockus, V. Tiesis and A. Zilinskas. The application of Bayesian
%       methods for seeking the extremum. In L.C.W. Dixon and G.P. Szego,
%       editors, Towards Global Optimization, volume 2, pages 117-129, North
%       Holland, New York, 1978.

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
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

function EI = stk_sampcrit_ei_eval (zp_mean, zp_std, zi)

if nargin > 4
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Evaluate the sampling criterion
EI = stk_distrib_normal_ei (min (zi), zp_mean, zp_std, true);

end % function


%!error EI = stk_sampcrit_ei_eval ()                % not enough args
%!error EI = stk_sampcrit_ei_eval (0)               % not enough args
%!error EI = stk_sampcrit_ei_eval (0, 0, 0, 0, 0)   % too many args

%%
% Compare various ways to compute the EI

%!shared xi, zi, M_prior, xt, zp, EIref, EI1, EI2, EI3
%! xi = [0; 0.2; 0.7; 0.9];
%! zi = [1; 0.9; 0.6; 0.1];
%! M_prior = stk_model('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);
%! xt = stk_sampling_regulargrid (20, 1, [0; 1]);
%! zp = stk_predict (M_prior, xi, zi, xt);
%! EIref = stk_distrib_normal_ei (min (zi), zp.mean, sqrt (zp.var), true);

%!test % Current syntax (STK 2.4.1 and later)
%! EI1 = stk_sampcrit_ei_eval (zp.mean, sqrt (zp.var), min (zi));

%!assert (isequal (EI1, EIref))
