% STK_COVMAT_GP0 [STK internal]
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

function [K, P1, P2] = stk_covmat_gp0 (model, x0, x1, diff, pairwise)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Check if the covariance model contains parameters
% that should have been estimated first
if (isnumeric (model.param)) && (any (isnan (model.param)))
    stk_error (['The covariance model contains undefined parameters, ' ...
        'which must be estimated first.'], 'ParametersMustBeEstimated');
end

x0 = double (x0);

if (nargin > 2) && (~ isempty (x1)),
    x1 = double (x1);
else
    x1 = x0;
end

% Defaut value for 'diff' (arg #4): -1
if nargin < 4,  diff = -1;  end

% Default value for 'pairwise' (arg #5): false
pairwise = (nargin > 4) && pairwise;

% Compute the covariance matrix
K = feval (model.covariance_type, model.param, x0, x1, diff, pairwise);

% No linear part for the 'gp0' component: return empty matrices if required
if nargout > 1
    P1 = zeros (size (x0, 1), 0);
    if nargout > 2
        P2 = zeros (size (x1, 2), 0);
    end
end

end % function


%!shared model, model2, x0, x1, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc, K1, K2, K3, P1, P2, P3
%! n0 = 20;  n1 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);  model.order = 1;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x0 = stk_sampling_randunif (n0, d);
%! x1 = stk_sampling_randunif (n1, d);

%!error [KK, PP] = stk_covmat_gp0 ();
%!error [KK, PP] = stk_covmat_gp0 (model);

%!test  [Ka, Pa] = stk_covmat_gp0 (model, x0);                        % (1)
%!test  [K1, P1] = stk_covmat_gp0 (model, x0, []);
%!test  [K2, P2] = stk_covmat_gp0 (model, x0, [], -1);
%!test  [K3, P3] = stk_covmat_gp0 (model, x0, [], -1, false);
%!error [KK, PP] = stk_covmat_gp0 (model, x0, [], -1, false, pi);
%!assert (isequal (size (Ka), [n0 n0]));
%!assert (isequal (size (Pa), [n0 0]));
%!assert (isequal (P1, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P2, Pa) && (isequal (K2, Ka)))
%!assert (isequal (P3, Pa) && (isequal (K3, Ka)))

%!test  [Kb, Pb] = stk_covmat_gp0 (model, x0, x0);                    % (2)
%!test  [K1, P1] = stk_covmat_gp0 (model, x0, x0, -1);
%!test  [K2, P2] = stk_covmat_gp0 (model, x0, x0, -1, false);
%!error [KK, PP] = stk_covmat_gp0 (model, x0, x0, -1, false, pi);
%!assert (isequal (size (Kb), [n0 n0]));
%!assert (isequal (size (Pb), [n0 0]));
%!assert (isequal (P1, Pb) && (isequal (K1, Kb)))
%!assert (isequal (P2, Pb) && (isequal (K1, Kb)))

%!test  [Kc, Pc] = stk_covmat_gp0 (model, x0, x1);                    % (3)
%!test  [K1, P1] = stk_covmat_gp0 (model, x0, x1, -1);
%!test  [K2, P2] = stk_covmat_gp0 (model, x0, x1, -1, false);
%!error [KK, PP] = stk_covmat_gp0 (model, x0, x1, -1, false, pi);
%!assert (isequal (size (Kc), [n0 n1]));
%!assert (isequal (size (Pc), [n0 0]));
%!assert (isequal (P1, Pc) && (isequal (K1, Kc)))
%!assert (isequal (P2, Pc) && (isequal (K1, Kc)))

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case as well, since we are only considering the gp0 component
%!test [Ka, Pa] = stk_covmat_gp0 (model2, x0);                      % (1')
%!test [Kb, Pb] = stk_covmat_gp0 (model2, x0, x0);                  % (2')
%!test assert (isequal (Kb, Ka));

% The second output depends on x0 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));