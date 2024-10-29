% STK_TESTFUN_SIXHUMPSCAMEL computes the "six humps camel back" function
%
% CALL: Y = stk_testfun_sixhumpscamel (X)
%
%    computes the value Y of the Hartman4 function at X.
%
%    The six humps camel back function is a test function in dimension 2,
%    which is usually evaluated over [-5, 5]^2.
%
% GLOBAL MINIMUM
%
%    According to [1], the function has two global minima at
%
%       x = [-0.0898, 0.7126]
%
%    and
%
%       x = [0.0898, -0.7126].
%
%    The corresponding function value is:
%
%       f(x) = -1.0316.
%
% REFERENCES
%
%  [1] M. Jamil & X. Yang, A Literature Survey of Benchmark Functions
%      For Global Optimization Problems. Int. Journal of Mathematical
%      Modelling and Numerical Optimisation, Vol. 4, No. 2, pp. 150–194
%      (2013).

% Copying Permission Statement  (this file)
%
%    Written in 2024 by Romain Ait Abdelmalek-Lomenech
%                                        <romain.ait@centralesupelec.fr>
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

function y = stk_testfun_sixhumpscamel (x)

x1 = x(:, 1);
x2 = x(:, 2);

A = (4 - (2.1 * x1 .^ 2) + (x1 .^ 4) / 3) .* (x1 .^ 2);
B = x1 .* x2;
C = 4 * (x2 .^ 2 - 1) .* (x2 .^ 2);

y = A + B + C;

end % function
