% STK_TESTFUN_HARTMAN4S computes the scaled "Hartman4" function
%
%    The scaled Hartman4 function is a test function in dimension 4,
%    which seems to have been introduced by [1].
%
%    It is usually minimized over [0, 1]^4.
%
% HISTORICAL REMARKS
%
%    This function belongs, up to a scaling, to a general class of test
%    functions introduced by Hartman [2].
%
%    Picheny & co-authors [1] refer to Dixon & Szego [3] for this test
%    function, but it turns out that [3] only contains two sorts of
%    "Hartman functions", in dimensions three and six.
%
%    In fact, this function appears to have been obtained by truncating
%    the sum at the fourth coordinate in the six-dimensional Hartman
%    function of [3] and then rescaling.
%
% IMPLEMENTATION
%
%    This implementation has been written from scratch using [1] as a
%    reference, and then checked for correctness with respect to [4, 5].
%
%    Only minor differences, of the order of 1e-15, were observed with
%    respect to [5].  The implementation in [4], however, uses a different
%    scaling: the leading term is 1/0.8387 instead of 1/0.839 in [1, 5].
%
% GLOBAL MINIMUM
%
%    According to [4], the function has one global minimum at
%
%       x = [0.1873 0.1906 0.5566 0.2647].
%
%    The corresponding function value, with our definition of the test
%    function taken from [1]  (the one in [4] uses a slightly different
%    normalizing constant, see above)  is:
%
%       f(x) = -3.134353168721454.
%
%    Slightly better function values can be found in the neighborhood of
%    this point.  For instance, with
%
%       x = [0.18744768 0.19414868 0.558005333 0.26476409]
%
%    we get
%
%       f(x) = -3.134493969530741.
%
% REFERENCES
%
%  [1] V. Picheny, T. Wagner & D. Ginsbourger (2013).  A benchmark
%      of kriging-based infill criteria for noisy optimization.
%      Structural and Multidisciplinary Optimization, 48:607-626.
%
%  [2] J. K. Hartman (1973).  Some experiments in global optimization.
%      Naval Research Logistics Quarterly, 20(3):569-576.
%
%  [3] L. C. W. Dixon & G. P. Szego (1978).  Towards Global
%      Optimization 2, North-Holland, Amsterdam, The Netherlands
%
%  [4] V. Picheny, D. Ginsbourger & O. Roustant (2021).  DiceOptim:
%      Kriging-Based Optimization for Computer Experiments.  R package
%      version 2.1.1.  URL: https://CRAN.R-project.org/package=DiceOptim.
%
%  [5] S. Surjanovic & D. Bingham.  Virtual Library of Simulation
%      Experiments: Test Functions and Datasets.  Retrieved March 3,
%      2022, https://www.sfu.ca/~ssurjano/hart4.html.

% Copyright Notice
%
%    Copyright (C) 2022 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement (STK toolbox as a whole)
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

% Copying Permission Statement (this file)
%
%    Redistribution and use  in source and binary forms,  with or without
%    modification,  are permitted provided that  the following conditions
%    are met:
%
%    1. Redistributions  of source code  must retain  the above copyright
%       notice,  this list of conditions and the following disclaimer.
%
%    2. Redistributions in binary form must reproduce the above copyright
%       notice,  this list of conditions  and the following disclaimer in
%       the documentation   and/or   other materials  provided  with  the
%       distribution.
%
%    3. Neither  the name  of the copyright holder  nor the names  of its
%       contributors may be used  to endorse or promote products  derived
%       from this software  without specific prior written permission.
%
%    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS  AND CONTRIBUTORS
%    "AS IS" AND ANY EXPRESS  OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT
%    LIMITED TO,  THE IMPLIED WARRANTIES  OF MERCHANTABILITY  AND FITNESS
%    FOR A  PARTICULAR PURPOSE  ARE DISCLAIMED.  IN  NO EVENT  SHALL  THE
%    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
%    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%    BUT NOT  LIMITED TO,  PROCUREMENT  OF SUBSTITUTE GOODS  OR SERVICES;
%    LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION)  HOWEVER
%    CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT,  STRICT
%    LIABILITY,  OR TORT (INCLUDING NEGLIGENCE  OR OTHERWISE)  ARISING IN
%    ANY WAY  OUT OF THE USE  OF THIS SOFTWARE,  EVEN  IF ADVISED  OF THE
%    POSSIBILITY OF SUCH DAMAGE.

function y = stk_testfun_hartman4s (x)

x = double (x);

assert (size (x, 2) == 4);

A = [                               ...
    [ 10.00   0.05   3.00  17.00 ]; ...
    [  3.00  10.00   3.50   8.00 ]; ...
    [ 17.00  17.00   1.70   0.05 ]; ...
    [  3.50   0.10  10.00  10.00 ]];

P = [                                  ...
    [ 0.1312  0.2329  0.2348  0.4047]; ...
    [ 0.1696  0.4135  0.1451  0.8828]; ...
    [ 0.5569  0.8307  0.3522  0.8732]; ...
    [ 0.0124  0.3736  0.2883  0.5743]];

C = [1.0  1.2  3.0  3.2];

% Compute inner sum
inner_sum = sum ( ...
    bsxfun (@times, shiftdim (A, -1), ...
    (bsxfun (@minus, x, shiftdim (P, -1))) .^ 2), 2);

% Compute the outer sum
outer_sum = sum (bsxfun (@times, shiftdim (C, -1), exp (- inner_sum)), 3);

% Final scaling
y = (1.1 - outer_sum) / 0.839;

end % function


%!test
%! x = [0.1873      0.1906      0.5566       0.2647     ;
%!      0.18744768  0.19414868  0.558005333  0.26476409];
%! y = stk_testfun_hartman4s (x);
%! assert (stk_isequal_tolabs (y, ...
%!     [-3.134353168721454; -3.134493969530741], 1e-15));
