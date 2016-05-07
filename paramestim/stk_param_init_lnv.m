% STK_PARAM_INIT_LNV provides a rough estimate of the variance of the noise
%
% CALL: LNV = stk_param_init_lnv (MODEL, XI, YI)
%
%   returns a rough estimate of the log of the noise variance computed using
%   the given MODEL and data (XI, YI), using the restricted maximum likelihood
%   (ReML) method. It selects the maximizer of the ReML criterion out of a
%   list of possible values.
%
% NOTE: assumption on the model
%
%   The model is assumed to be a stationary Gaussian process, with
%   model.param(1) corresponding to the log of the Gaussian process variance.
%   This assumption is currently fulfilled by all the models shipped with STK.
%
% See also: stk_param_estim, stk_param_init

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function lnv = stk_param_init_lnv (model, xi, zi)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% size checking: xi, zi
if ~ isequal (size (zi), [size(xi, 1) 1]),
    errmsg = 'zi should be a column, with the same number of rows as xi.';
    stk_error (errmsg, 'IncorrectSize');
end

% Warn about special case: constant response
if (std (double (zi)) == 0)
    warning ('STK:stk_param_estim_lnv:ConstantResponse', ['Constant- ' ...
        'response data: the output of stk_param_estim_lnv is likely ' ...
        'to be unreliable.']);
end

% Make sure that lognoisevariance is -inf for noiseless models
if ~ stk_isnoisy (model)
    model.lognoisevariance = -inf;
end

% We will work with the ratio eta = sigma2_noise / sigma2
log_eta_min = -15;  % exp(-15) = 3e-7 approx  -> very small noise
log_eta_max = +15;  % exp(+15) = 3e+7 approx  -> very large noise
log_eta_list = linspace (log_eta_min, log_eta_max, 5);

% Initialize parameter search
log_eta_best = nan;
aLL_best = +inf;

% Try all values from log_eta_list
for log_eta = log_eta_list
    model.lognoisevariance = model.param(1) + log_eta;
    aLL = stk_param_relik (model, xi, zi);
    if (~ isnan (aLL)) && (aLL < aLL_best)
        log_eta_best = log_eta;
        aLL_best    = aLL;
    end
end

if isinf (aLL_best)
    errmsg = 'Couldn''t find reasonable parameter values... ?!?';
    stk_error (errmsg, 'AlgorithmFailure');
end

lnv = model.param(1) + log_eta_best;

end % function


%!test
%! f = @(x)(- (0.8 * x + sin (5 * x + 1) + 0.1 * sin (10 * x)));
%! ni = 20;
%! xi = (linspace (-1, 1, ni))' + 0.2 * (randn (ni, 1));
%! zi = stk_feval (f, xi);
%!
%! model = stk_model ('stk_materncov_iso');
%! model.param = log ([1; 5/2; 1/0.4]);
%! lnv = stk_param_init_lnv (model, xi, zi);
%!
%! assert ((isscalar (lnv)) && (lnv > -30) && (lnv < 30));
