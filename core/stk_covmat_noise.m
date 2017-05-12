% STK_COVMAT_NOISE [STK internal]
%
% CALL: [K, P1, P2] = stk_covmat_noise (M, X1, X2, DIFF, PAIRWISE)
%
% DIFF can be -1, 0, or 1
%
% See also: stk_covmat

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

function [K, P1, P2] = stk_covmat_noise (model, x1, x2, diff, pairwise)
% STK internal function => no check for nargin > 5

% Number of evaluations points
n1 = size (x1, 1);
if (nargin > 2) && (~ isempty (x2))
    n2 = size (x2, 1);
    autocov = false;  % In this case the result is zero
else
    n2 = n1;
    autocov = true;   % In this case the result is a diagonal matrix
end

% Defaut value for 'diff' (arg #4): -1
if nargin < 4,  diff = -1;  end

% Default value for 'pairwise' (arg #5): false
pairwise = (nargin > 4) && pairwise;

if autocov && (diff ~= 0) && (stk_isnoisy (model))
    
    if isa(model.lognoisevariance, 'stk_noisevar_param')
        K = stk_noisecov(model.lognoisevariance, x1, diff, pairwise, []);
    else % if isnumeric(model.lognoisevariance) % old compatibility
        if isscalar (model.lognoisevariance) % Homoscedastic case
            
            % Note: the value of x1 is ignored in this case, which is normal.
            %       Only the size of x1 actually matters.
            
            % Currently there is only one parameter (lognoisevariance).
            % This will change when we implement parameterized variance models...
            if (diff ~= -1) && (diff ~= 1)
                stk_error (['diff should be either -1 or +1 in the ' ...
                    'homoscedastic case'], 'IncorrectArgument');
            end
            
            if pairwise
                if model.lognoisevariance == -inf
                    K = zeros (n1, 1);
                else
                    K = (exp (model.lognoisevariance)) * (ones (n1, 1));
                end
            else
                if model.lognoisevariance == -inf
                    K = zeros (n1);
                else
                    K = (exp (model.lognoisevariance)) * (eye (n1));
                end
            end
            
        else % Heteroscedastic
            
            % Note: the value of x1 is *also* ignored in this case, which is
            %       much less normal...  This will change soon.
            
            % Old-style STK support for heteroscedasticity: the noise variances
            % corresponding to the locations x1(1,:) to x1(end,:) are assumed to
            % be stored in model.lognoisevariance (ugly).
            
            s = size (model.lognoisevariance);
            if ~ ((isequal (s, [1, n1])) || (isequal (s, [n1, 1])))
                fprintf ('lognoisevariance has size:\n');  display (s);
                stk_error (sprintf (['lognoisevariance was expected to be either a ' ...
                    'scalar or a vector of length %d\n'], n1), 'IncorrectSize');
            end
            
            % Currently there are no parameters in this case.
            % This will change when we implement parameterized variance models...
            if diff ~= -1,
                error ('diff ~= -1 is not allowed in the heteroscedastic case');
            end
            
            if pairwise
                K = exp (model.lognoisevariance(:));
            else
                K = diag (exp (model.lognoisevariance));
            end
        end
    end
    
else  % Return a null matrix
    
    % There are several cases where we return a null matrix:
    % a) autocov is false: we are actually computing a *cross*-covariance matrix
    % b) diff = 0: derivative with respect to a parameter that does not modify
    %    the covariance matrix of the noise
    % c) we are in the noiseless case.
    
    K = zeros (n1, n2);
    
end


%% Compute matrices for the linear part

% No linear part for the 'noise' output: return empty matrices if required
if nargout > 1
    P1 = zeros (n1, 0);
    
    if nargout > 2
        P2 = zeros (n2, 0);
    end
end

end % function


%!shared model, model2, x1, x2, n1, n2, d, Ka, Kb, Kc, Pa, Pb, Pc, P1, P2, P3, K1, K2, K3
%! n1 = 20;  n2 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);
%! model.lm = stk_lm_affine;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x1 = stk_sampling_randunif (n1, d);
%! x2 = stk_sampling_randunif (n2, d);

%!error [KK, PP] = stk_covmat_noise ();
%!error [KK, PP] = stk_covmat_noise (model);

%!test  [Ka, Pa] = stk_covmat_noise (model, x1);                           % (1)
%!test  [K1, P1] = stk_covmat_noise (model, x1, []);
%!test  [K2, P2] = stk_covmat_noise (model, x1, [], -1);
%!test  [K3, P3] = stk_covmat_noise (model, x1, [], -1, false);
%!assert (isequal (size (Ka), [n1 n1]));
%!assert (isequal (size (Pa), [n1 0]));
%!assert (isequal (P1, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P2, Pa) && (isequal (K2, Ka)))
%!assert (isequal (P3, Pa) && (isequal (K3, Ka)))

%!test  [Kb, Pb] = stk_covmat_noise (model, x1, x1);                       % (2)
%!test  [K1, P1] = stk_covmat_noise (model, x1, x1, -1);
%!test  [K2, P2] = stk_covmat_noise (model, x1, x1, -1, false);
%!assert (isequal (size (Kb), [n1 n1]));
%!assert (isequal (size (Pb), [n1 0]));
%!assert (isequal (P1, Pb) && (isequal (K1, Kb)))
%!assert (isequal (P2, Pb) && (isequal (K2, Kb)))

%!test  [Kc, Pc] = stk_covmat_noise (model, x1, x2);                       % (3)
%!test  [K1, P1] = stk_covmat_noise (model, x1, x2, -1);
%!test  [K2, P2] = stk_covmat_noise (model, x1, x2, -1, false);
%!assert (isequal (size (Kc), [n1 n2]));
%!assert (isequal (size (Pc), [n1 0]));
%!assert (isequal (P1, Pc) && (isequal (K1, Kc)))
%!assert (isequal (P2, Pc) && (isequal (K2, Kc)))

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case, however...
%!test  [Ka, Pa] = stk_covmat_noise (model2, x1);                         % (1')
%!test  [Kb, Pb] = stk_covmat_noise (model2, x1, x1);                     % (2')
%!error assert (isequal (Kb, Ka));

% The second output depends on x1 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));
