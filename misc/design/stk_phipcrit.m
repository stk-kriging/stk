% STK_PHIPCRIT computes the "phi_p" criterion of Morris & Mitchell
%
% CALL: D = stk_phipcrit (X, P)
%
%    computes the phi_P criterion on the set of points X, which is defined for
%    an n x d array X as
%
%       D = (sum_{1 <= i < j <= n} d_ij ^ (-p)) ^ (1/p)
%
%    where d_ij is the Euclidean distance in R^d between X(i,:) and X(j,:).
%
% CALL: D = stk_phipcrit (X)
%
%    computes the phi_P criterion with P = 50.
%
% NOTES:
%
%    * In the special case P = 2, this criterion has first been introduced by
%      Audze & Eglais (1977).
%
%    * When p -> +Inf, the value of the phi_p criterion tends to the inverse of
%      the mindist criterion. The phi_p criterion with a high value of p is
%      often used in place of the mindist criterion for its being easier to
%      optimize. Morris & Mitchell recommend using p in the range 20-50 for this
%      purpose.
%
% REFERENCES
%
%   [1] Max D. Morris and Toby J. Mitchell, "Exploratory Designs for Computer
%       Experiments", Journal of Statistical Planning and Inference,
%       43(3):381-402, 1995.
%
%   [2] P. Audze and V. Eglais, "New approach for planning out experiments",
%       Problems of Dynamics and Strengths, 35:104-107, 1977.
%
%   [3] Luc Pronzato and Werner G. Muller, "Design of computer
%       experiments: space filling and beyond", Statistics and Computing,
%       22(3):681-701, 2012.
%
%   [4] G. Damblin, M. Couplet and B. Iooss, "Numerical studies of space filling
%       designs: optimization of Latin hypercube samples and subprojection
%       properties", Journal of Simulation, in press.
%
% See also: stk_mindist, stk_filldist

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

function phi = stk_phipcrit (x, p)

if nargin > 2
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 2,
    p = 50;
end

% compute the distance matrix
D = stk_dist (x);

% compute mindist
D = D + diag (inf (1, size (x, 1)));
z = min (D(:));

% compute the value of the criterion
if z > 0
    tmp = triu ((D / z) .^ (-p), 1);
    phi = 1 / z * sum(tmp(:)) .^ (1/p);
else
    phi = Inf;
end

end % function


%!shared x
%! x = [0, 0.2, 0.4, 0.6, 0.8, 1.0;
%!      0, 0.6, 0.8, 1.0, 0.2, 0.4]';

%!assert (stk_isequal_tolabs ...
%!          (stk_phipcrit (x, 10), 3.946317664423303, 1e-15))

%!assert (stk_isequal_tolabs ...
%!          (stk_phipcrit (x, 50), 3.614077252813102, 1e-15));

%!assert (stk_isequal_tolabs ...
%!          (stk_phipcrit (x, 100), 3.574589859827413, 1e-15));

%!assert (stk_isequal_tolabs ...
%!          (stk_phipcrit (x, 1e9), 1 / stk_mindist (x), 1e-8));

%!assert (isequal (stk_phipcrit (ones (2)), Inf));

% library (DiceDesign)   # load DiceDesign 1.2
% options (digits = 16)  # display 16 significat digits
%
% x <- data.frame (x1 = c(0, 0.2, 0.4, 0.6, 0.8, 1.0),
%                  x2 = c(0, 0.6, 0.8, 1.0, 0.2, 0.4))
%
% phiP (x, 10)    # 3.946317664423303
% phiP (x, 50)    # 3.614077252813102
% phiP (x, 100)   # 3.574589859827413
% phiP (x, 1000)  # Inf, but we can do better
