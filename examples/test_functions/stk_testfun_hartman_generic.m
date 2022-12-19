% STK_TESTFUN_HARTMAN_GENERIC compute the value of a Hartman function
%
% CALL: Y = stk_testfun_hartman_generic (X, A, P, C)
% 
%    computes the value Y of the Hartman function with parameters A, P, C,
%    at the points contained in X.
%
%    The size of Y is N x 1, where N is the number of rows of X.
%
%    The parameters A, P and C should have size N x D, N x D and 1 x D
%    respectively, where D is the number of columns of X.
%
% HISTORICAL NOTE
%
%    This class of test functions has been introduced by Hartman [2],
%    hence the name.  The particular form of Hartman functions considered
%    here, however, seems to have been introduced by [1].
%
%    The only difference between the particular form considered in [1] and
%    the general form in [2] is that the weighting matrix for the quadratic
%    form in the exponential is assumed to be diagonal.
%
% REFERENCES
%
%  [1] L. C. W. Dixon & G. P. Szego (1978).  Towards Global
%      Optimization 2, North-Holland, Amsterdam, The Netherlands
%
%  [2] J. K. Hartman (1973).  Some experiments in global optimization.
%      Naval Research Logistics Quarterly, 20(3):569-576.
%
%  [3] V. Picheny, T. Wagner & D. Ginsbourger (2013).  A benchmark
%      of kriging-based infill criteria for noisy optimization.
%      Structural and Multidisciplinary Optimization, 48:607-626.
%
%  [4] MCS: Global Optimization by Multilevel Coordinate Search.
%      Version 2.0 from Feb. 8, 2000.  Retrieved on March 10, 2022,
%      from https://www.mat.univie.ac.at/~neum/software/mcs/
%
%  [5] S. Surjanovic & D. Bingham.  Virtual Library of Simulation
%      Experiments: Test Functions and Datasets.  Retrieved March 3,
%      2022, https://www.sfu.ca/~ssurjano/hart4.html.
%
% See also stk_testfun_hartman3, stk_testfun_hartman4, stk_testfun_hartman6

% Author
%
%    Julien Bect  <julien.bect@centralesupelec.fr>

% IMPLEMENTATION
%
%    This implementation has been written from scratch using [1, 3] as
%    references (omitting the scaling in [3]).  Other implementations
%    available on the web, such as [4, 5], have only been used to check
%    the results for some special cases (Hartman3 and Hartman6 functions).

% Copying Permission Statement  (this file)
%
%    To the extent possible under law, CentraleSupelec has waived all
%    copyright and related or neighboring rights to
%    stk_testfun_hartman_generic.m.  This work is published from France.
%
%    License: CC0  <http://creativecommons.org/publicdomain/zero/1.0/>

% Copying Permission Statement  (STK toolbox as a whole)
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

function y = stk_testfun_hartman_generic (x, A, P, C)

x = double (x);

d = size (x, 2);
m = size (A, 2);

assert (isequal (size (A), [d m]));
assert (isequal (size (P), [d m]));
assert (isequal (size (C), [1 m]));

% Compute inner sum
inner_sum = sum ( ...
    bsxfun (@times, shiftdim (A, -1), ...
    (bsxfun (@minus, x, shiftdim (P, -1))) .^ 2), 2);

% Compute the outer sum
y = - sum (bsxfun (@times, shiftdim (C, -1), exp (- inner_sum)), 3);

end % function
