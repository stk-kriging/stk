% STK_COVMAT_RESPONSE [STK internal]
%
% CALL: [K, P1, P2] = stk_covmat_response (M, X1, X2, DIFF, PAIRWISE)
%
% DIFF can be -1, 0, or anything <= NCOVPARAM + 1
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

function [K, P1, P2] = stk_covmat_response (varargin)
% Input arguments: model, x1, x2, diff, pairwise
% STK internal function => no check for nargin > 5

K_noise = stk_covmat_noise (varargin{:});

switch nargout
    
    case {0, 1}  % K only
        K_gp = stk_covmat_latent (varargin{:});
        
    case 2  % K, P1
        [K_gp, P1] = stk_covmat_latent (varargin{:});
        
    case 3  % K, P1 and P2
        [K_gp, P1, P2] = stk_covmat_latent (varargin{:});
        
end

K = K_gp + K_noise;

end % function


%!shared model, model2, x1, x2, n1, n2, d, Ka, Kb, Kc, Pa, Pb, Pc, P1, P2, P3, K1, K2, K3
%! n1 = 20;  n2 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);
%! model.lm = stk_lm_affine;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x1 = stk_sampling_randunif (n1, d);
%! x2 = stk_sampling_randunif (n2, d);

%!error [KK, PP] = stk_covmat_response ();
%!error [KK, PP] = stk_covmat_response (model);

%!test  [Ka, Pa] = stk_covmat_response (model, x1);                        % (1)
%!test  [K1, P1] = stk_covmat_response (model, x1, []);
%!test  [K2, P2] = stk_covmat_response (model, x1, [], -1);
%!test  [K3, P3] = stk_covmat_response (model, x1, [], -1, false);
%!error [KK, PK] = stk_covmat_response (model, x1, [], -1, false, pi);
%!assert (isequal (size (Ka), [n1 n1]));
%!assert (isequal (size (Pa), [n1 d+1]));
%!assert (isequal (P1, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P2, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P3, Pa) && (isequal (K3, Ka)))

%!test  [Kb, Pb] = stk_covmat_response (model, x1, x1);                    % (2)
%!test  [K1, P1] = stk_covmat_response (model, x1, x1, -1);
%!test  [K2, P2] = stk_covmat_response (model, x1, x1, -1, false);
%!error [K2, P2] = stk_covmat_response (model, x1, x1, -1, false, pi);
%!assert (isequal (size (Kb), [n1 n1]));
%!assert (isequal (size (Pb), [n1 d+1]));
%!assert (isequal (P1, Pb) && (isequal (K1, Kb)))
%!assert (isequal (P2, Pb) && (isequal (K1, Kb)))

%!test  [Kc, Pc] = stk_covmat_response (model, x1, x2);                    % (3)
%!test  [K1, P1] = stk_covmat_response (model, x1, x2, -1);
%!test  [K2, P2] = stk_covmat_response (model, x1, x2, -1, false);
%!error [KK, PP] = stk_covmat_response (model, x1, x2, -1, false, pi);
%!assert (isequal (size (Kc), [n1 n2]));
%!assert (isequal (size (Pc), [n1 d+1]));
%!assert (isequal (P1, Pc) && (isequal (K1, Kc)))
%!assert (isequal (P2, Pc) && (isequal (K1, Kc)))

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case, however...
%!test  [Ka, Pa] = stk_covmat_response (model2, x1);                      % (1')
%!test  [Kb, Pb] = stk_covmat_response (model2, x1, x1);                  % (2')
%!error assert (isequal (Kb, Ka));

% The second output depends on x1 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));
