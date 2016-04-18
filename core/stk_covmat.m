% STK_COVMAT computes a covariance matrix
%
% CALL: K = stk_covmat (M, OUTPUT, X)
% CALL: K = stk_covmat (M, OUTPUT, X, [], -1, false)
%
%    computes the covariance matrix K for the values of OUTPUT at locations
%    X(1, :), ..., X(N, :) according to model M.  The model M can be either a
%    prior model, currently described in STK using model structures (see
%    stk_model), or a posterior model (object of class stk_model_gpposterior).
%    The OUTPUT argument can take the following values:
%
%     * 'response' for the covariance matrix of future responses, which are
%       evaluations of the latent process, possibly corrupted by independent
%       Gaussian noise,
%
%     * 'latent' for the covariance matrix of latent process values only
%       (i.e., without the variance of the noise added to the diagonal),
%
%     * 'noise' for the (diagonal) covariance matrix of the noise,
%
%     * 'lm' for the linear model component of the latent process,
%
%     * and 'gp0' for the zero-mean GP component of the latent process.
%
%   The argument X is expected to be an N x DIM array, where DIM is the input
%   space dimension for model M. The result is a symmetric N x N matrix.
%
%   The OUTPUT argument can be omitted in the case of a noiseless model, in
%   which case K is the covariance matrix of the latent GP, which is also the
%   covariance matrix of future responses (since repeated measurements yield
%   identical responses in the noiseless case).
%
%   The prior models used in STK are in general improper models, since an
%   improper uniform prior is assumed for the coefficient of the linear model.
%   In this case, the covariance matrix K returned by stk_covmat is the
%   covariance matrix of the *proper* part of the model.
%
% CALL: [K, P] = stk_covmat (M, OUTPUT, X)
% CALL: [K, P] = stk_covmat (M, OUTPUT, X, [], -1, false)
%
%   also returns the associated N x L matrix P (which corresponds to the
%   so-called "design matrix" in linear regression models), in the case where
%   M is an improper prior model with a linear component of dimension L (e.g.,
%   L = 1 if MODEL.order is zero).
%
% CALL: [K, P1, P2] = stk_covmat (M, OUTPUT, X1, X2)
% CALL: [K, P1, P2] = stk_covmat (M, OUTPUT, X1, X2, -1, false)
%
%   computes the cross-covariance matrix K for sets of locations X1 and X2, and
%   also (optionally) computes the associated matrices P1 and P2 for the linear
%   model component.  Even if X1 and X2 share some common rows, it is assumed
%   that they correspond to *distinct* measurements at the same location; in
%   other words, the variance of the noise is not added to the corresponding
%   covariance matrix elements.
%
% CALL: [dK, dP1, dP2] = stk_covmat (M, OUTPUT, X1, X2, DIFF)
% CALL: [dK, dP1, dP2] = stk_covmat (M, OUTPUT, X1, X2, DIFF, false)
%
%   returns the derivatives of K, P1, P2 with respect to parameter number DIFF
%   in the model.  Currently, parameterized linear models are not supported and
%   therefore dP1 and dP2 are always equal to zero.  With DIFF equal to -1, no
%   derivation is performed (this is the default value).
%
% CALL: [Kd, P1, P2] = stk_covmat (M, OUTPUT, X,  [], DIFF, PAIRWISE)
% CALL: [Kd, P1, P2] = stk_covmat (M, OUTPUT, X1, X2, DIFF, PAIRWISE)
%
%   only returns the diagonal Kd of the covariance matrix K if PAIRWISE is true,
%   and the full covariance matrix if PAIRWISE is false (this is the default).
%   For the second syntax, X1 and X2 must have the same size when PAIRWISE is
%   true.

% Copyright Notice
%
%    Copyright (C) 2015, 2016 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function varargout = stk_covmat (prior_model, varargin)

if nargin < 2,
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

% Note: stk_covmat is overloaded for posterior model objects (i.e., objects of
% class stk_model_gpposterior).  There, we can assume here that the first
% argument is a prior model structure (although perhaps it would be cleaner to
% check it).

% Backward compatibility:
%   accept model structures with missing 'lognoisevariance' field
if (~ isfield (prior_model, 'lognoisevariance')) ...
        || (isempty (prior_model.lognoisevariance))
    prior_model.lognoisevariance = - inf;
end

% Check if 'output' has been provided
if ischar (varargin{1})
    output = varargin{1};
    varargin = varargin(2:end);
else
    if isequal (prior_model.lognoisevariance, -inf)
        output = 'latent';
    else
        stk_error (['The ''output'' argument of stk_covmat can only be ' ...
            'omitted for noiseless models.'], 'SyntaxError');
    end
end

% Call the appropriate function to compute the result(s)
varargout = cell (1, max (1, nargout));
switch output
    case 'response'
        [varargout{:}] = stk_covmat_response (prior_model, varargin{:});
    case 'latent'
        [varargout{:}] = stk_covmat_latent (prior_model, varargin{:});
    case 'noise'
        [varargout{:}] = stk_covmat_noise (prior_model, varargin{:});
    case 'lm'
        [varargout{:}] = stk_covmat_lm (prior_model, varargin{:});
    case 'gp0'
        [varargout{:}] = stk_covmat_gp0 (prior_model, varargin{:});
    otherwise
        stk_error (sprintf ('Incorrect output name: %s', output), ...
            'IncorrectArgument');
end

end % function


%!shared model, model2, x0, x1, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc, P1, P2, P3, K1, K2, K3
%! n0 = 20;  n1 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);  model.order = 1;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x0 = stk_sampling_randunif (n0, d);
%! x1 = stk_sampling_randunif (n1, d);

%!error [KK, PP] = stk_covmat ();
%!error [KK, PP] = stk_covmat (model);

%!test  [Ka, Pa] = stk_covmat (model, x0);                         % (1)
%!test  [K1, P1] = stk_covmat (model, x0, []);
%!test  [K2, P2] = stk_covmat (model, x0, [], -1);
%!test  [K3, P3] = stk_covmat (model, x0, [], -1, false);
%!error [KK, PP] = stk_covmat (model, x0, [], -1, false, pi);
%!assert (isequal (size (Ka), [n0 n0]));
%!assert (isequal (size (Pa), [n0 d+1]));
%!assert (isequal (P1, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P2, Pa) && (isequal (K2, Ka)))
%!assert (isequal (P3, Pa) && (isequal (K3, Ka)))

%!test  [Kb, Pb] = stk_covmat (model, x0, x0);                    % (2)
%!test  [K1, P1] = stk_covmat (model, x0, x0, -1);
%!test  [K2, P2] = stk_covmat (model, x0, x0, -1, false);
%!assert (isequal (size (Kb), [n0 n0]));
%!assert (isequal (size (Pb), [n0 d+1]));
%!assert (isequal (P1, Pb) && (isequal (K1, Kb)))
%!assert (isequal (P2, Pb) && (isequal (K2, Kb)))

%!test  [Kc, Pc] = stk_covmat (model, x0, x1);                    % (3)
%!test  [K1, P1] = stk_covmat (model, x0, x1, -1);
%!test  [K2, P2] = stk_covmat (model, x0, x1, -1, false);
%!error [KK, PP] = stk_covmat (model, x0, x1, -1, false, pi);
%!assert (isequal (size (Kc), [n0 n1]));
%!assert (isequal (size (Pc), [n0 d+1]));
%!assert (isequal (P1, Pc) && (isequal (K1, Kc)))
%!assert (isequal (P2, Pc) && (isequal (K2, Kc)))

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case, however...
%!test  [Ka, Pa] = stk_covmat (model2, 'response', x0);           % (1')
%!test  [Kb, Pb] = stk_covmat (model2, 'response', x0, x0);       % (2')
%!error assert (isequal (Kb, Ka));

% The second output depends on x0 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));
