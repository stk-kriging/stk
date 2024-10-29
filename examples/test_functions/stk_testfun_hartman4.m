% STK_TESTFUN_HARTMAN4 computes the "Hartman4" function
%
% CALL: Y = stk_testfun_hartman4 (X)
%
%    computes the value Y of the Hartman4 function at X.
%
%    The Hartman4 function is a test function in dimension 4,
%    which is usually minimized over [0, 1]^4.
%
% HISTORICAL REMARKS
%
%    This function belongs to a general class of test functions introduced
%    by Hartman [1].  The particular set of coefficients used in the
%    Hartman4 function seems to have been introduced by [2].
%
%    Note that the test function used in [2] is a scaled version of the
%    one implemented here, which can be recovered as follows:
%
%      y = (1.1 + stk_testfun_hartman4 (x)) / 0.839;
%
%    Picheny & co-authors [2] refer to Dixon & Szego [3] for this test
%    function, but it turns out that [3] only contains two sorts of
%    "Hartman functions", in dimensions three and six.
%
%    In fact, this function appears to have been obtained by truncating
%    the sum at the fourth coordinate in the six-dimensional Hartman
%    function of [3].
%
% GLOBAL MINIMUM
%
%    According to [4], the function has one global minimum at
%
%       x = [0.1873 0.1906 0.5566 0.2647].
%
%    The corresponding function value, with our definition of the test
%    function, is:
%
%       f(x) = -3.729722308557300.
%
%    Slightly better function values can be found in the neighborhood of
%    this point.  For instance, with
%
%       x = [0.18744768 0.19414868 0.558005333 0.26476409]
%
%    we get
%
%       f(x) = -3.729840440436292.
%
% REFERENCES
%
%  [1] J. K. Hartman (1973).  Some experiments in global optimization.
%      Naval Research Logistics Quarterly, 20(3):569-576.
%
%  [2] V. Picheny, T. Wagner & D. Ginsbourger (2013).  A benchmark
%      of kriging-based infill criteria for noisy optimization.
%      Structural and Multidisciplinary Optimization, 48:607-626.
%
%  [3] L. C. W. Dixon & G. P. Szego (1978).  Towards Global
%      Optimization 2, North-Holland, Amsterdam, The Netherlands
%
%  [4] V. Picheny, D. Ginsbourger & O. Roustant (2021).  DiceOptim:
%      Kriging-Based Optimization for Computer Experiments.  R package
%      version 2.1.1.  URL: https://CRAN.R-project.org/package=DiceOptim.

% Copying Permission Statement  (this file)
%
%    Written in 2022 by Julien Bect <julien.bect@centralesupelec.fr>
%
%    To the extent possible under law, CentraleSupelec has dedicated all
%    copyright and related and neighboring rights to this software to the
%    public domain worldwide. This software is distributed without any
%    warranty.
%
%    You should have received a copy of the CC0 Public Domain Dedication
%    along with this software. If not, see
%                    <http://creativecommons.org/publicdomain/zero/1.0/>.

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

function y = stk_testfun_hartman4 (x)

a = [                               ...
    [ 10.00   0.05   3.00  17.00 ]; ...
    [  3.00  10.00   3.50   8.00 ]; ...
    [ 17.00  17.00   1.70   0.05 ]; ...
    [  3.50   0.10  10.00  10.00 ]];

p = [                                  ...
    [ 0.1312  0.2329  0.2348  0.4047]; ...
    [ 0.1696  0.4135  0.1451  0.8828]; ...
    [ 0.5569  0.8307  0.3522  0.8732]; ...
    [ 0.0124  0.3736  0.2883  0.5743]];

c = [1.0  1.2  3.0  3.2];

y = stk_testfun_hartman_generic (x, a, p, c);

end % function


%!test
%! x = [0.1873      0.1906      0.5566       0.2647     ;
%!      0.18744768  0.19414868  0.558005333  0.26476409];
%! y = stk_testfun_hartman4 (x);
%! assert (stk_isequal_tolabs (y, ...
%!     [-3.729722308557300; -3.729840440436292], 1e-15));
