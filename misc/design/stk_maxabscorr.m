% STK_MAXABSCORR computes the maximal absolute correlation for a set of points
%
% CALL: MAC = stk_maxabscorr (X)
%
%    computes the Maximum Absolute (linear) Correlation MAC between the columns
%    of the array X.
%
% NOTES:
%
%    * The construction of experimental designs (more specifically, Latin 
%      hypercubes samples) with a small MAC is considered, e.g., by Florian
%      (1992) and Cioppa & Lucas (2007).
%
%    * When X is a Latin hypercube sample, the linear (Pearson) correlation
%      coefficients and Spearman's rank correlation coefficients coincide.
%
% REFERENCES
%
%   [1] Ales Florian, "An Efficient Sampling Scheme: Updated Latin Hypercube
%       Sampling", Probabilistic Engineering Mechanics, 7:123-130, 1992.
%       http://dx.doi.org/10.1016/0266-8920(92)90015-A
%
%   [2] Thomas M. Cioppa and Thomas W. Lucas, "Efficient Nearly Orthogonal and
%       Space-Filling Latin Hypercubes, Technometrics, 49:1, 45-55, 2007.
%       http://dx.doi.org/10.1198/004017006000000453
%
% See also: stk_mindist, stk_filldist, stk_phipcrit

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013 SUPELEC
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

function mac = stk_maxabscorr (x)

if nargin > 1
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

x = double (x);
x = bsxfun (@minus, x, mean (x));

n = size (x, 2);

M = 0;
for i = 1:(n-1)
    for j = (i+1):n
        M = max (M, abs (sum (x(:, i) .* x(:, j))));
    end
end

mac = M / n;

end % function


%!assert (stk_isequal_tolabs (0.0, ...   % Test on an OLHS(5)
%!           stk_maxabscorr ([0.4 0.8 0 -0.4 -0.8; -0.8 0.4 0 0.8 -0.4]')));
