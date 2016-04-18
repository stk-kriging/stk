% STK_COVMAT_NOISE [STK internal]
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

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Backward compatiblity: accept model structures with missing lognoisevariance
if (~ isfield (model, 'lognoisevariance')) || (isempty (model.lognoisevariance))
    model.lognoisevariance = - inf;
end

% Number of evaluations points
x1 = double (x1);  % Do not remove: necessary for legacy .a structures
n1 = size (x1, 1);
if (nargin > 2) && (~ isempty (x2)),
    x2 = double (x2);  % Do not remove: necessary for legacy .a structures
    n2 = size (x2, 1);
    make_matcov_auto = false;  % In this case the result is zero
else
    n2 = n1;
    make_matcov_auto = true;   % In this case the result is a diagonal matrix
end

% Defaut value for 'diff' (arg #4): -1
if nargin < 4,  diff = -1;  end

% Default value for 'pairwise' (arg #5): false
pairwise = (nargin > 4) && pairwise;

%%
% Compute the covariance matrix

if make_matcov_auto && (any (model.lognoisevariance ~= -inf))
    
    if isscalar (model.lognoisevariance) % Homoscedastic case
        
        % Note: the value of x1 is ignored in this case, which is normal.
        %       Only the size of x1 actually matters.
        
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
    
else % Cross-covariance between independent noise values OR noiseless case
    
    K = zeros (n1, n2);
    
end

%%
% No linear part for the 'noise' output: return empty matrices if required

if nargout > 1
    P1 = zeros (n1, 0);
    
    if nargout > 2
        P2 = zeros (n2, 0);
    end
end

end % function


%!shared model, model2, x0, x1, n0, n1, d, Ka, Kb, Kc, Pa, Pb, Pc, P1, P2, P3, K1, K2, K3
%! n0 = 20;  n1 = 10;  d = 4;
%! model = stk_model ('stk_materncov52_aniso', d);  model.order = 1;
%! model.param = log ([1.0; 2.1; 2.2; 2.3; 2.4]);
%! model2 = model;  model2.lognoisevariance = log(0.01);
%! x0 = stk_sampling_randunif (n0, d);
%! x1 = stk_sampling_randunif (n1, d);

%!error [KK, PP] = stk_covmat_noise ();
%!error [KK, PP] = stk_covmat_noise (model);

%!test  [Ka, Pa] = stk_covmat_noise (model, x0);                           % (1)
%!test  [K1, P1] = stk_covmat_noise (model, x0, []);
%!test  [K2, P2] = stk_covmat_noise (model, x0, [], -1);
%!test  [K3, P3] = stk_covmat_noise (model, x0, [], -1, false);
%!error [KK, PP] = stk_covmat_noise (model, x0, [], -1, false, pi);
%!assert (isequal (size (Ka), [n0 n0]));
%!assert (isequal (size (Pa), [n0 0]));
%!assert (isequal (P1, Pa) && (isequal (K1, Ka)))
%!assert (isequal (P2, Pa) && (isequal (K2, Ka)))
%!assert (isequal (P3, Pa) && (isequal (K3, Ka)))

%!test  [Kb, Pb] = stk_covmat_noise (model, x0, x0);                       % (2)
%!test  [K1, P1] = stk_covmat_noise (model, x0, x0, -1);
%!test  [K2, P2] = stk_covmat_noise (model, x0, x0, -1, false);
%!error [KK, PP] = stk_covmat_noise (model, x0, x0, -1, false, pi);
%!assert (isequal (size (Kb), [n0 n0]));
%!assert (isequal (size (Pb), [n0 0]));
%!assert (isequal (P1, Pb) && (isequal (K1, Kb)))
%!assert (isequal (P2, Pb) && (isequal (K2, Kb)))

%!test  [Kc, Pc] = stk_covmat_noise (model, x0, x1);                       % (3)
%!test  [K1, P1] = stk_covmat_noise (model, x0, x1, -1);
%!test  [K2, P2] = stk_covmat_noise (model, x0, x1, -1, false);
%!error [KK, PP] = stk_covmat_noise (model, x0, x1, -1, false, pi);
%!assert (isequal (size (Kc), [n0 n1]));
%!assert (isequal (size (Pc), [n0 0]));
%!assert (isequal (P1, Pc) && (isequal (K1, Kc)))
%!assert (isequal (P2, Pc) && (isequal (K2, Kc)))

% In the noiseless case, (1) and (2) should give the same results
%!assert (isequal (Kb, Ka));

% In the noisy case, however...
%!test  [Ka, Pa] = stk_covmat_noise (model2, x0);                         % (1')
%!test  [Kb, Pb] = stk_covmat_noise (model2, x0, x0);                     % (2')
%!error assert (isequal (Kb, Ka));

% The second output depends on x0 only => should be the same for (1)--(3)
%!assert (isequal (Pa, Pb));
%!assert (isequal (Pa, Pc));
