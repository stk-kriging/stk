% STK_PREDICT_ [STK internal]
%
% See also: stk_predict

% Copyright Notice
%
%    Copyright (C) 2020 CentraleSupelec
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

function [zp, lambda, mu, K] = stk_predict_ (model, xt)

% If we end up here, model must be a prior model struct (as opposed to a
% model object).  Better safe than sorry:
stk_assert_model_struct (model);

nt = stk_get_sample_size (xt);

% Is it a proper or an improper prior?
model = stk_model_fixlm (model);
if isa (model.lm, 'stk_lm_null')
    % Proper prior (currently, zero-mean only)
    zp_mean = zeros (nt, 1);
else
    % Improper prior
    zp_mean = nan (nt, 1);
end

if nargout > 3
    K = stk_make_matcov (model, xt, xt, false);
    zp_var = diag (K);
else
    zp_var = stk_make_matcov (model, xt, xt, true);
end

zp = stk_dataframe ([zp_mean zp_var], {'mean' 'var'});

if nargout > 1  % We want lambda

    % lambda must be n x nt, with n the sample size (here n = 0)
    lambda = zeros (0, nt);
    
    if nargout > 2  % We want mu as well
        
        % UGLY: we have no cleaner way to find the dimension...
        x_ = xt(1, :);
        [K_ignore, P] = stk_make_matcov (model, x_, x_);  %#ok<ASGLU>
        r = size (P, 2);
        
        % mu must be r x nt, and setting it to zero in this case makes
        % sense because the posterior variance formula remains valid
        mu = zeros (r, nt);
    end
end

end % function
