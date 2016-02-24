% STK_TESTFUN_BRANINHOO computes the Branin-Hoo function.
%
%    The Branin-Hoo function (Branin and Hoo, 1972) is a classical test
%    function for global optimization algorithms, which belongs to the
%    well-known Dixon-Szego test set (Dixon and Szego, 1978). It is usually
%    minimized over [-5; 10] x [0; 15].
%
% REFERENCES
%
%  [1] Branin, F. H. and Hoo, S. K. (1972), A Method for Finding Multiple
%      Extrema of a Function of n Variables, in Numerical methods of
%      Nonlinear Optimization (F. A. Lootsma, editor, Academic Press,
%      London), 231-237.
%
%  [2] Dixon L.C.W., Szego G.P., Towards Global Optimization 2, North-
%      Holland, Amsterdam, The Netherlands (1978)

% Copyright Notice
%
%    Copyright (C) 2012-2014 SUPELEC
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

function y = stk_testfun_braninhoo (x)

x = double (x);

x1 = x(:, 1);
x2 = x(:, 2);

a = 5.1 / (4 * pi * pi);
b = 5 / pi;
c = 10 * (1 - 1 / (8 * pi));

y = (x2 - a * x1 .* x1 + b * x1 - 6) .^ 2 + c * cos (x1) + 10;

end % function
