% STK_COVMAT_GP0 [STK internal]
%
% CALL: [K, P1, P2] = stk_covmat_gp0 (M, X1, X2, DIFF, PAIRWISE)
%
% INTERNAL FUNCTION WARNING:
%    This function is currently considered as internal: API-breaking changes are
%    likely to happen in future releases.  Please don't rely on it directly.
%
% See also: stk_covmat

% Copyright Notice
%
%    Copyright (C) 2015, 2016, 2018 CentraleSupelec
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

function [K, P1, P2] = stk_covmat_gp0 (model, x1, x2, diff, pairwise)
% STK internal function => no check for nargin > 5

% Check if the covariance model contains parameters
% that should have been estimated first
param = stk_get_optimizable_parameters (model.param);
if any (isnan (param))
    stk_error (['The covariance model contains undefined parameters, ' ...
        'which must be estimated first.'], 'ParametersMustBeEstimated');
end

% Evaluation points
n1 = size (x1, 1);
if (nargin > 2) && (~ isempty (x2))
    n2 = size (x2, 1);
else
    x2 = x1;
    n2 = n1;
end

% Defaut value for 'diff' (arg #4): -1
if nargin < 4,  diff = -1;  end

% Default value for 'pairwise' (arg #5): false
pairwise = (nargin > 4) && pairwise;

if (diff == -1) || (diff > 0 && diff <= length (param))
    
    K = feval (model.covariance_type, model.param, x1, x2, diff, pairwise);
    
else  % Incorrect valuefor the 'diff' argument
    
    stk_error ('Incorrect diff value.', 'IncorrectArgument');
    
end % if

% No linear part for the 'gp0' component: return empty matrices if required
if nargout > 1
    P1 = zeros (n1, 0);
    
    if nargout > 2
        P2 = zeros (n2, 0);
    end
end

end % function


%!shared model, model2, x1, x2, n1, n2, d, Ka, Kb, Kc, Pa, Pb, Pc, K1, K2, K3, P1, P2, P3
%! n1 = 20;  n2 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);
%! model.lm = stk_lm_affine;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x1 = stk_sampling_randunif (n1, d);
%! x2 = stk_sampling_randunif (n2, d);

%!error [KK, PP] = stk_covmat_gp0 ();
%!error [KK, PP] = stk_covmat_gp0 (model);

%!test  [Ka, Pa] = stk_covmat_gp0 (model, x1);                        % (1)
%!test  [K1, P1] = stk_covmat_gp0 (model, x1, []);
%!test  [K2, P2] = stk_covmat_gp0 (model, x1, [], -1);
%!test  [K3, P3] = stk_covmat_gp0 (model, x1, [], -1, false);
%!assert (isequal (size (Ka), [n1 n1]));
%!assert (isequal (size (Pa), [n1 0]));
%!assert (isequal (P1, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P2, Pa) && (isequal (K2, Ka)))
%!assert (isequal (P3, Pa) && (isequal (K3, Ka)))

%!test  [Kb, Pb] = stk_covmat_gp0 (model, x1, x1);                    % (2)
%!test  [K1, P1] = stk_covmat_gp0 (model, x1, x1, -1);
%!test  [K2, P2] = stk_covmat_gp0 (model, x1, x1, -1, false);
%!assert (isequal (size (Kb), [n1 n1]));
%!assert (isequal (size (Pb), [n1 0]));
%!assert (isequal (P1, Pb) && (isequal (K1, Kb)))
%!assert (isequal (P2, Pb) && (isequal (K1, Kb)))

%!test  [Kc, Pc] = stk_covmat_gp0 (model, x1, x2);                    % (3)
%!test  [K1, P1] = stk_covmat_gp0 (model, x1, x2, -1);
%!test  [K2, P2] = stk_covmat_gp0 (model, x1, x2, -1, false);
%!assert (isequal (size (Kc), [n1 n2]));
%!assert (isequal (size (Pc), [n1 0]));
%!assert (isequal (P1, Pc) && (isequal (K1, Kc)))
%!assert (isequal (P2, Pc) && (isequal (K1, Kc)))

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case as well, since we are only considering the gp0 component
%!test [Ka, Pa] = stk_covmat_gp0 (model2, x1);                      % (1')
%!test [Kb, Pb] = stk_covmat_gp0 (model2, x1, x1);                  % (2')
%!test assert (isequal (Kb, Ka));

% The second output depends on x1 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));