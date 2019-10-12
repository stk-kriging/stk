% STK_COVMAT_NULL [STK internal]
%
% CALL: [K, P1, P2] = stk_covmat_null (M, X1, X2, DIFF, PAIRWISE)
%
% INTERNAL FUNCTION WARNING:
%    This function is currently considered as internal: API-breaking changes are
%    likely to happen in future releases.  Please don't rely on it directly.
%
% See also: stk_covmat

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%
%    Author:  Julien Bect       <julien.bect@centralesupelec.fr>

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

function [K, P1, P2] = stk_covmat_null (model, x1, x2, diff, pairwise)  %#ok<INUSL>
% STK internal function => no check for nargin > 5

% Evaluation points
n1 = size (x1, 1);
if (nargin > 2) && (~ isempty (x2))
    n2 = size (x2, 1);
else
    n2 = n1;
end

% Compute the covariance matrix
if (nargin > 4) && pairwise
    assert (n1 == n2);
    K = zeros (n1, 1);
else
    K = zeros (n1, n2);
end

% Compute matrices for the linear part
if nargout > 1
    P1 = zeros (n1, 0);
    
    if nargout > 2
        P2 = zeros (n2, 0);
    end
end

end % function
