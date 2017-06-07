% @STK_SAMPCRIT_AKG/FEVAL [overload base function]
%
% See also: feval

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

function [AKG, zp] = feval (crit, x, varargin)

% Implementation note: stk_predict currently does not offer the possibility to
% get the right-hand side of the kriging equation, which is needed here.  So,
% instead of calling stk_predict, we manipulate here the kriging equation object
% directly...

kreq = stk_make_kreq (crit.model, x);

prior_model = get_prior_model (crit.model);

zc_mean  = (get (kreq, 'lambda'))' * (double (get_output_data (crit.model)));
zc_var   = stk_make_matcov (prior_model, x, x, true) - get (kreq, 'delta_var');
zc_std   = sqrt (max (0, zc_var));
zcr_cov0 = stk_make_matcov (prior_model, x, crit.xr);
zcr_cov  = zcr_cov0 - (get (kreq, 'RS'))' * crit.zr_lambdamu;

AKG = stk_sampcrit_akg_eval ...
    (zc_mean, zc_std, crit.zr_mean, crit.zr_std, zcr_cov);

if nargout > 1
    zp = stk_dataframe ([zc_mean zc_var], {'mean' 'var'});
end

% FIXME: Loop over blocks, as in stk_predict ?

end % function
