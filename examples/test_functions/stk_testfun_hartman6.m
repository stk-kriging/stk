% STK_TESTFUN_HARTMAN6 computes the "Hartman6" function
%
%    The Hartman6 function is a test function in dimension 6, which is
%    part of the famous Dixon & Szego benchmark [1] in global optimization.
%
%    It is usually minimized over [0, 1]^6.
%
% HISTORICAL REMARKS
%
%    This function belongs to a general class of test functions
%    introduced by Hartman [2], hence the name.
%
%    The particular set of coefficients used in the definition of the
%    "Hartman6" function, however, seems to have been introduced by [1].
%
% IMPLEMENTATION
%
%    This implementation has been written from scratch using [1, 3] as
%    a reference (omitting the scaling in [3]) and then checked for
%    correctness with respect to [4, 5].
%
%    Only minor differences (at most 7e-16) were observed with respect
%    to [5].  None with respect to [4].
%
% GLOBAL MINIMUM
%
%    According to [5], the function has one global minimum at
%
%       x = [0.20169 0.150011 0.476874 0.275332 0.311652 0.657300].
%
%    The corresponding function value is:
%
%       f(x) = -3.322368011391339
%
%    A slightly lower value is attained [6] at
%
%       x = [0.20168952 0.15001069 0.47687398 ...
%            0.27533243 0.31165162 0.65730054]
%
%    The corresponding function value is:
%
%       f(x) = -3.322368011415512
%
%    The exact global optimum does not appear to be known.
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
%  [6] O. Roustant, D. Ginsbourger & Y. Deville (2012).
%      DiceKriging package, version 1.6.0 from 2021-02-23
%      URL: https://cran.r-project.org/web/packages/DiceKriging/index.html

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

function y = stk_testfun_hartman6 (x)

x = double (x);

assert (size (x, 2) == 6);

A = [                               ...
    [ 10.00   0.05   3.00  17.00 ]; ...
    [  3.00  10.00   3.50   8.00 ]; ...
    [ 17.00  17.00   1.70   0.05 ]; ...
    [  3.50   0.10  10.00  10.00 ]; ...
    [  1.70   8.00  17.00   0.10 ]; ...
    [  8.00  14.00   8.00  14.00 ]];

P = [                                   ...
    [ 0.1312  0.2329  0.2348  0.4047 ]; ...
    [ 0.1696  0.4135  0.1451  0.8828 ]; ...
    [ 0.5569  0.8307  0.3522  0.8732 ]; ...
    [ 0.0124  0.3736  0.2883  0.5743 ]; ...
    [ 0.8283  0.1004  0.3047  0.1091 ]; ...
    [ 0.5886  0.9991  0.6650  0.0381 ]];

C = [1.0  1.2  3.0  3.2];

% Compute inner sum
inner_sum = sum ( ...
    bsxfun (@times, shiftdim (A, -1), ...
    (bsxfun (@minus, x, shiftdim (P, -1))) .^ 2), 2);

% Compute the outer sum
y = - sum (bsxfun (@times, shiftdim (C, -1), exp (- inner_sum)), 3);

end % function


%!test
%! x1 = [0.20169 0.150011 0.476874 0.275332 0.311652 0.657300];
%! y1 = -3.322368011391339;
%!
%! x2 = [0.20168952 0.15001069 0.47687398 0.27533243 0.31165162 0.65730054];
%! y2 = -3.322368011415512;
%!
%! y = stk_testfun_hartman6 ([x1; x2]);
%! assert (stk_isequal_tolabs (y, [y1; y2], 1e-15))
