% STK_NULLCOV computes a null covariance matrix
%
% The syntax is similar to other STK covariance functions.
%
% CALL: K = stk_nullcov (PARAM, X, Y)
%
% CALL: dK = stk_nullcov (PARAM, X, Y, DIFF)
%
% CALL: K = stk_nullcov (PARAM, X, Y, DIFF, PAIRWISE)
%
% where PARAM should be [].

% Copyright Notice
%
%    Copyright (C) 2021 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%                 (https://github.com/stk-kriging/stk/)
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

function K = stk_nullcov (param, x1, x2, diff, pairwise)  %#ok<INUSL>

% Number of evaluations points
n1 = size (x1, 1);
if (nargin > 2) && (~ isempty (x2))
    n2 = size (x2, 1);
else
    n2 = n1;
end

% Default value for 'pairwise' (arg #5): false
pairwise = (nargin > 4) && pairwise;
assert ((n1 == n2) || (~ pairwise));

% Return a matrix of zeros
if pairwise
    K = zeros (n1, 1);
else
    K = zeros (n1, n2);
end

end % function
