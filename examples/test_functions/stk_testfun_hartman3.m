% STK_TESTFUN_HARTMAN3 computes the "Hartman3" function
%
%    The Hartman3 function is a test function in dimension 3, which is
%    part of the famous Dixon & Szego benchmark [1] in global optimization.
%
%    It is usually minimized over [0, 1]^3.
%
% HISTORICAL REMARKS
%
%    This function belongs to a general class of test functions
%    introduced by Hartman [2], hence the name.
%
%    The particular set of coefficients used in the definition of the
%    "Hartman3" function, however, seems to have been introduced by [1].
%
% GLOBAL MINIMUM
%
%    According to [5], the function has one global minimum at
%
%       x = [0.1, 0.55592003, 0.85218259].
%
%    The corresponding function value is:
%
%       f(x) = -3.862634748621772.
%
%    A slightly lower value is attained [4] at
%
%       x = [0.114614 0.554649 0.852547].
%
%    The corresponding function value is:
%
%       f(x) = -3.862747199255087
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
%  [4] S. Surjanovic & D. Bingham.  Virtual Library of Simulation
%      Experiments: Test Functions and Datasets.  Retrieved March 3,
%      2022, https://www.sfu.ca/~ssurjano/hart4.html.
%
%  [5] O. Roustant, D. Ginsbourger & Y. Deville (2012).
%      DiceKriging package, version 1.6.0 from 2021-02-23
%      URL: https://cran.r-project.org/web/packages/DiceKriging/index.html

% Author
%
%    Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement  (this file)
%
%    To the extent possible under law, CentraleSupelec has waived all
%    copyright and related or neighboring rights to
%    stk_testfun_hartman3.m.  This work is published from France.
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

function y = stk_testfun_hartman3 (x)

a = [                          ...
    [  3.0   0.1   3.0   0.1]; ...
    [ 10.0  10.0  10.0  10.0]; ...
    [ 30.0  35.0  30.0  35.0]];

p = [                                   ...
    [ 0.3689  0.4699  0.1091  0.03815]; ...
    [ 0.1170  0.4387  0.8732  0.57430]; ...
    [ 0.2673  0.7470  0.5547  0.88280]];

c = [1.0  1.2  3.0  3.2];

y = stk_testfun_hartman_generic (x, a, p, c);

end % function


%!test
%! x1 = [0.1, 0.55592003, 0.85218259];
%! y1 = -3.862634748621772;
%!
%! x2 = [0.114614 0.554649 0.852547];
%! y2 = -3.862747199255087;
%!
%! y = stk_testfun_hartman3 ([x1; x2]);
%! assert (stk_isequal_tolabs (y, [y1; y2], 1e-15))
