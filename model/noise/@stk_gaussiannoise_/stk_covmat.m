% STK_COVMAT [STK internal]
%
% INTERNAL FUNCTION WARNING:
%    This function is currently considered as internal: API-breaking changes are
%    likely to happen in future releases.  Please don't rely on it directly.

% Copyright Notice
%
%    Copyright (C) 2017, 2018, 2020 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function [K, P1, P2] = stk_covmat (gn, x1, x2, diff, pairwise)

% Auto- or cross-covariance matrix ?
% (for noise models, cross-covariance matrices are equal to zero)
autocov = (nargin <= 2) || (isequal (x2, []));

% Process input argument: x1
if isa (x1, 'stk_iodata')
    if autocov
        nrep = x1.output_nrep;
    end
    x1 = stk_get_input_data (x1);
else
    nrep = [];
end
n1 = stk_get_sample_size (x1);

% Process input argument: x2
if autocov
    n2 = n1;
else
    n2 = stk_get_sample_size (x2);
end

% Defaut value for 'diff' (arg #4): -1
if nargin < 4,  diff = -1;  end

% Default value for 'pairwise' (arg #5): false
pairwise = (nargin > 4) && pairwise;
assert ((n1 == n2) || (~ pairwise));

if autocov
    
    K = stk_variance_eval (gn, x1, diff);
    assert (isequal (size (K), [n1 1]));
    
    if ~ isempty (nrep)
        K = K ./ nrep;
    end
    
    if ~ pairwise
        K = diag (K);
    end
    
else  % autocov is false: Return a null matrix
    
    if pairwise
        K = zeros (n1, 1);
    else
        K = zeros (n1, n2);
    end
    
end

% No linear part
if nargout > 1
    P1 = zeros (n1, 0);
    if nargout > 2
        P2 = zeros (n2, 0);
    end
end

end % function
